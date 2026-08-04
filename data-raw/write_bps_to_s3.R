# Run devtools::load_all() before executing this script.
# Loads processing helpers: .probe_latest_bps_year(), read_bps_raw(), .compute_bps_variables()
devtools::load_all()

write_bps_to_s3 <- function(
    years          = 2000:.probe_latest_bps_year(),
    s3_bucket      = "cori.data.bps",
    s3_path_prefix = "",
    overwrite      = FALSE,
    sync_to_s3     = TRUE
) {

  if (!requireNamespace("cori.data.pep", quietly = TRUE)) {
    stop(
      "cori.data.pep is required to compute units_per_1k_people. ",
      "Install with: remotes::install_github('ruralinnovation/cori.data.pep')"
    )
  }

  # --- Population denominator from cori.data.pep ---
  message("Pulling population from cori.data.pep...")
  pop_raw <- cori.data.pep::read_pep_from_s3(variables = "population", years = years)

  pop_county <- pop_raw |>
    dplyr::filter(nchar(geoid) == 5) |>
    dplyr::select(geoid, year, pop = value)

  pop_state <- pop_county |>
    dplyr::mutate(geoid = substr(geoid, 1, 2)) |>
    dplyr::group_by(geoid, year) |>
    dplyr::summarise(pop = sum(pop, na.rm = TRUE), .groups = "drop")

  pop_national <- pop_county |>
    dplyr::group_by(year) |>
    dplyr::summarise(pop = sum(pop, na.rm = TRUE), .groups = "drop") |>
    dplyr::mutate(geoid = "00")

  pop_df <- dplyr::bind_rows(pop_county, pop_state, pop_national)

  # --- Raw data ---
  message(sprintf("Reading raw BPS data for %d years...", length(years)))
  raw <- dplyr::bind_rows(lapply(years, read_bps_raw))

  raw_dir <- file.path(tempdir(), "bps", "raw")
  dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  DBI::dbWriteTable(con, "raw_bps", raw, overwrite = TRUE)
  DBI::dbExecute(con, sprintf(
    "COPY raw_bps TO '%s' (FORMAT 'parquet', PARTITION_BY (year), OVERWRITE_OR_IGNORE)",
    raw_dir
  ))
  message(sprintf("Raw data written locally: %s rows", format(nrow(raw), big.mark = ",")))

  # --- Processed data ---
  message("Computing building_permits and units_per_1k_people...")
  processed   <- .compute_bps_variables(raw, pop_df)
  vintage     <- as.character(max(processed$year, na.rm = TRUE))
  vintage_tag <- sprintf("vintage_%s", vintage)

  message(sprintf("Vintage: %s | Rows: %s", vintage, format(nrow(processed), big.mark = ",")))

  processed_dir <- file.path(tempdir(), "bps", "processed", vintage_tag)
  dir.create(processed_dir, recursive = TRUE, showWarnings = FALSE)

  DBI::dbWriteTable(con, "processed_bps", processed, overwrite = TRUE)
  DBI::dbExecute(con, sprintf(
    "COPY processed_bps TO '%s' (FORMAT 'parquet', PARTITION_BY (year), OVERWRITE_OR_IGNORE)",
    processed_dir
  ))

  # _LATEST pointer
  latest_dir  <- file.path(tempdir(), "bps", "processed")
  latest_file <- file.path(latest_dir, "_LATEST")
  writeLines(vintage_tag, latest_file)

  # --- Upload to S3 ---
  if (sync_to_s3) {
    s3_raw_prefix <- sprintf("%sdata_raw/", s3_path_prefix)
    if (overwrite) {
      s3_raw_uri <- sprintf("s3://%s/%s", s3_bucket, s3_raw_prefix)
      message(sprintf("Deleting existing S3 prefix: %s", s3_raw_uri))
      base::system2("aws", args = c("s3", "rm", s3_raw_uri, "--recursive"))
    }
    .upload_to_s3(s3_bucket, s3_raw_prefix, raw_dir)

    s3_processed_prefix <- sprintf("%sdata_processed/%s/", s3_path_prefix, vintage_tag)
    if (overwrite) {
      s3_processed_uri <- sprintf("s3://%s/%s", s3_bucket, s3_processed_prefix)
      message(sprintf("Deleting existing S3 prefix: %s", s3_processed_uri))
      base::system2("aws", args = c("s3", "rm", s3_processed_uri, "--recursive"))
    }
    .upload_to_s3(s3_bucket, s3_processed_prefix, processed_dir)
    .upload_to_s3(
      s3_bucket,
      sprintf("%sdata_processed/_LATEST", s3_path_prefix),
      latest_file
    )
    message(sprintf("_LATEST updated to: %s", vintage_tag))
  }

  invisible(list(vintage = vintage, n_rows = nrow(processed)))
}


# Internal: upload a directory or single file to S3 via AWS CLI.
.upload_to_s3 <- function(s3_bucket, s3_prefix, local_path) {
  s3_uri <- sprintf("s3://%s/%s", s3_bucket, s3_prefix)
  message(sprintf("Uploading to %s...", s3_uri))

  if (isTRUE(file.info(local_path)$isdir)) {
    exit_code <- base::system2("aws", args = c("s3", "sync", local_path, s3_uri))
  } else {
    exit_code <- base::system2("aws", args = c("s3", "cp", local_path, s3_uri))
  }

  if (exit_code != 0) stop(sprintf("AWS CLI upload failed: %s -> %s", local_path, s3_uri))
}
