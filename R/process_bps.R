# Internal: compute units_per_1k from a pre-loaded raw df and pop df.
# raw_df: output of read_bps_raw() bound across years
# pop_df: data frame with columns geoid, year, pop
.compute_units_per_1k <- function(raw_df, pop_df) {
  raw_df |>
    dplyr::mutate(
      total_units = single_family_units + units_2_family +
                    units_3_to_4_family + units_5_plus_family
    ) |>
    dplyr::select(geoid, year, total_units) |>
    dplyr::left_join(pop_df, by = c("geoid", "year")) |>
    dplyr::mutate(
      agg_var  = pop / 1000,
      value    = total_units / agg_var,
      value    = dplyr::if_else(is.infinite(value), NA_real_, value),
      agg_var  = dplyr::if_else(is.na(value), NA_real_, agg_var),
      variable = "units_per_1k_people"
    ) |>
    dplyr::select(geoid, year, variable, value, agg_var)
}


#' Pull units per 1,000 population
#'
#' Reads raw BPS data from the Census Bureau for the requested years,
#' joins with a population data frame, and returns the five-column tidy format.
#'
#' @param years Integer vector. Years to pull.
#' @param pop_df Data frame with columns \code{geoid}, \code{year}, \code{pop}.
#'   Obtain from \code{cori.data.pep::read_pep_from_s3(variables = "population")},
#'   then rename \code{value} to \code{pop} and drop \code{variable}/\code{agg_var}.
#'
#' @return A data frame: \code{geoid}, \code{year}, \code{variable},
#'   \code{value}, \code{agg_var}.
#'
#' @keywords internal
#' @export
pull_units_per_1k <- function(years, pop_df) {
  raw <- dplyr::bind_rows(lapply(years, read_bps_raw))
  .compute_units_per_1k(raw, pop_df)
}
