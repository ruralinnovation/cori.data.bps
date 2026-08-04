# Internal: probe Census Bureau to find the latest year with available BPS data.
.probe_latest_bps_year <- function() {
  year <- as.integer(format(Sys.Date(), "%Y"))
  repeat {
    url <- sprintf("https://www2.census.gov/econ/bps/County/co%da.txt", year)
    status <- tryCatch(
      {
        con <- url(url)
        open(con, "r")
        close(con)
        200L
      },
      error = function(e) 404L
    )
    if (status == 200L) return(year)
    year <- year - 1L
    if (year < 2000L) stop("Could not find any available BPS data year.", call. = FALSE)
  }
}


# Internal: compute building_permits and units_per_1k from a pre-loaded raw df and pop df.
# raw_df: output of read_bps_raw() bound across years
# pop_df: data frame with columns geoid, year, pop
.compute_bps_variables <- function(raw_df, pop_df) {
  totals <- raw_df |>
    dplyr::mutate(
      total_units = single_family_units + units_2_family +
                    units_3_to_4_family + units_5_plus_family
    ) |>
    dplyr::select(geoid, year, total_units)

  permits <- totals |>
    dplyr::mutate(variable = "building_permits", value = as.numeric(total_units), agg_var = NA_real_) |>
    dplyr::select(geoid, year, variable, value, agg_var)

  per_1k <- totals |>
    dplyr::left_join(pop_df, by = c("geoid", "year")) |>
    dplyr::mutate(
      agg_var  = pop / 1000,
      value    = total_units / agg_var,
      value    = dplyr::if_else(is.infinite(value), NA_real_, value),
      agg_var  = dplyr::if_else(is.na(value), NA_real_, agg_var),
      variable = "units_per_1k_people"
    ) |>
    dplyr::select(geoid, year, variable, value, agg_var)

  dplyr::bind_rows(permits, per_1k)
}


#' Pull BPS processed variables
#'
#' Reads raw BPS data from the Census Bureau for the requested years,
#' joins with a population data frame, and returns the five-column tidy format
#' for both `building_permits` and `units_per_1k_people`.
#'
#' @param years Integer vector. Years to pull.
#' @param pop_df Data frame with columns \code{geoid}, \code{year}, \code{pop}.
#'
#' @return A data frame: \code{geoid}, \code{year}, \code{variable},
#'   \code{value}, \code{agg_var}.
#'
#' @keywords internal
pull_units_per_1k <- function(years, pop_df) {
  raw <- dplyr::bind_rows(lapply(years, read_bps_raw))
  .compute_bps_variables(raw, pop_df)
}
