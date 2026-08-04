#' Get the cori.data.bps variable codebook
#'
#' Returns a data frame describing each variable available from
#' [get_building_permits()].
#'
#' @return A data frame with columns: `variable`, `raw_variable`, `label`,
#'   `unit`, `nominal`, `notes`.
#'   `raw_variable` is the original name stored in S3 parquet files.
#'
#' @seealso [get_building_permits()]
#'
#' @examples
#' get_bps_codebook()
#'
#' @export
get_bps_codebook <- function() {
  data.frame(
    stringsAsFactors = FALSE,

    variable = c(
      "building_permits",
      "units_per_1k_people"
    ),

    raw_variable = c(
      "building_permits",
      "units_per_1k_people"
    ),

    label = c(
      "New residential units authorized",
      "New residential units authorized per 1,000 population"
    ),

    unit = c(
      "units",
      "units per 1,000 persons"
    ),

    nominal = c(TRUE, FALSE),

    notes = c(
      paste0(
        "Total new residential units authorized by building permits (all structure types). ",
        "Sum of single-family, 2-family, 3-to-4-family, and 5-plus-family units. ",
        "Coverage: 2000-present. ",
        "Geography: county (5-digit FIPS), state (2-digit FIPS), national ('00')."
      ),
      paste0(
        "Total new residential units authorized divided by resident population in thousands. ",
        "Population denominator from Census Population Estimates Program via cori.data.pep. ",
        "agg_var = population / 1,000, suitable for population-weighted averaging. ",
        "Coverage: 2000-present. ",
        "Geography: county (5-digit FIPS), state (2-digit FIPS), national ('00')."
      )
    )
  )
}
