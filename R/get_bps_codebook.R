#' Get the cori.data.bps variable codebook
#'
#' Returns documentation for all variables in the processed BPS output.
#'
#' @return A data frame with columns: \code{variable}, \code{label},
#'   \code{unit}, \code{nominal}, \code{notes}.
#'
#' @seealso \code{\link{read_bps_from_s3}}
#'
#' @examples
#' get_bps_codebook()
#'
#' @export
get_bps_codebook <- function() {
  data.frame(
    stringsAsFactors = FALSE,
    variable = "units_per_1k_people",
    label    = "New residential units authorized per 1,000 population",
    unit     = "units per 1,000 persons",
    nominal  = FALSE,
    notes    = paste0(
      "Total new residential units authorized (all structure types) divided by ",
      "resident population in thousands. Population denominator from ",
      "cori.data.pep (Census Population Estimates Program). ",
      "agg_var is population / 1,000, suitable for population-weighted averaging. ",
      "Coverage: 2000-present. Geography: county (5-digit FIPS), ",
      "state (2-digit FIPS), national (\"00\")."
    )
  )
}
