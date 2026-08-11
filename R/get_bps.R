#' Get Building Permits Survey data
#'
#' Queries CORI's processed Building Permits Survey (BPS) parquet files from S3
#' using DuckDB. Returns long-format data: one row per `geoid / year / variable`.
#'
#' @import DBI
#' @importFrom cori.data.s3 connect_to_s3
#'
#' @param geography Character. One of `"all"`, `"county"`, `"state"`, or
#'   `"nation"`. Filters rows by geography level. Default: `"all"`.
#' @param years Integer vector. Years to return. Default: all available.
#' @param geoids Character vector. FIPS codes to return (5-digit county,
#'   2-digit state, or `"00"` for national). When supplied, overrides
#'   `geography`. Default: all.
#' @param variables Character vector. Variables to return. Default: all.
#'   See [get_bps_codebook()] for valid names.
#' @param vintage Character. Vintage to read, e.g. `"2024"`. Default:
#'   `"latest"`, which reads the `_LATEST` pointer written by
#'   `write_bps_to_s3()`.
#'
#' @return A data frame with columns: `geoid`, `year`, `variable`, `value`,
#'   `agg_var`. `agg_var` is population / 1,000, suitable for
#'   population-weighted averaging of `units_per_1k_people`.
#'
#' @seealso [get_bps_codebook()]
#'
#' @examples
#' \dontrun{
#' get_building_permits(geography = "county")
#' get_building_permits(geography = "county", years = 2010:2024)
#' get_building_permits(geoids = c("33009", "33", "00"))
#' }
#'
#' @export
get_building_permits <- function(
    geography = c("county", "state", "nation"),
    years     = NULL,
    geoids    = NULL,
    variables = NULL,
    vintage   = "latest"
) {
  geography <- match.arg(geography)

  vintage_tag <- if (vintage == "latest") {
    .latest_bps_vintage()
  } else {
    if (!startsWith(vintage, "vintage_")) sprintf("vintage_%s", vintage) else vintage
  }

  con <- cori.data.s3::connect_to_s3("cori.data.bps")
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  DBI::dbExecute(con, sprintf("SET temp_directory = '%s';", tempdir()))

  glob  <- sprintf(
    "s3://cori.data.bps/data_processed/%s/**/*.parquet",
    vintage_tag
  )
  query <- sprintf(
    "SELECT geoid, year, variable, value, agg_var FROM read_parquet('%s', hive_partitioning = true)",
    glob
  )

  where <- character(0)
  if (!is.null(geoids)) {
    where <- c(where, sprintf("geoid IN (%s)", paste0("'", geoids, "'", collapse = ", ")))
  }
  if (!is.null(years)) {
    where <- c(where, sprintf("year IN (%s)", paste(years, collapse = ", ")))
  }
  if (!is.null(variables)) {
    where <- c(where, sprintf("variable IN (%s)", paste0("'", variables, "'", collapse = ", ")))
  }
  if (length(where) > 0) {
    query <- paste(query, "WHERE", paste(where, collapse = " AND "))
  }

  df <- DBI::dbGetQuery(con, query) |>
    dplyr::mutate(
      geoid   = as.character(geoid),
      year    = as.integer(year),
      value   = as.numeric(value),
      agg_var = as.numeric(agg_var)
    )

  df <- .apply_bps_geography_filter(df, geography, geoids)

  geo_label <- switch(geography,
    county = "county",
    state  = "state",
    nation = "national",
    "county"
  )

  message(sprintf(
    "cori.data.bps: %s | vintage: %s | %s rows",
    geo_label, vintage_tag, format(nrow(df), big.mark = ",")
  ))

  df
}


.latest_bps_vintage <- function(s3_bucket = "cori.data.bps", s3_path_prefix = "") {
  url <- sprintf(
    "https://s3.us-east-1.amazonaws.com/%s/%sdata_processed/_LATEST",
    s3_bucket, s3_path_prefix
  )
  tryCatch(
    readLines(url, n = 1L, warn = FALSE),
    error = function(e) stop(sprintf(
      "Could not read _LATEST from s3://%s/%sdata_processed/_LATEST.",
      s3_bucket, s3_path_prefix
    ))
  )
}


.apply_bps_geography_filter <- function(df, geography, geoids) {
  if (!is.null(geoids)) return(df)
  switch(geography,
    county = dplyr::filter(df, nchar(geoid) == 5),
    state  = dplyr::filter(df, nchar(geoid) == 2),
    nation = dplyr::filter(df, geoid == "00"),
    df
  )
}
