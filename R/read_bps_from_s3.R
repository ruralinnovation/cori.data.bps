#' Read processed BPS data from S3
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `read_bps_from_s3()` is deprecated. Use [get_building_permits()] instead.
#'
#' @param vintage Passed to [get_building_permits()].
#' @param variables Passed to [get_building_permits()].
#' @param years Passed to [get_building_permits()].
#' @param geoids Passed to [get_building_permits()].
#' @param s3_bucket Ignored. No longer configurable in the public API.
#' @param s3_path_prefix Ignored. No longer configurable in the public API.
#'
#' @return A data frame. See [get_building_permits()] for details.
#'
#' @seealso [get_building_permits()]
#'
#' @export
read_bps_from_s3 <- function(
    vintage        = "latest",
    variables      = NULL,
    years          = NULL,
    geoids         = NULL,
    s3_bucket      = "cori.data.bps",
    s3_path_prefix = ""
) {
  .Deprecated(
    new     = "get_building_permits",
    package = "cori.data.bps",
    msg     = paste0(
      "`read_bps_from_s3()` is deprecated. Use `get_building_permits()` instead.\n",
      "  Note: `s3_bucket` and `s3_path_prefix` are no longer configurable in the public API."
    )
  )
  get_building_permits(
    years     = years,
    geoids    = geoids,
    variables = variables,
    vintage   = vintage
  )
}


#' @keywords internal
latest_bps_vintage <- function(s3_bucket = "cori.data.bps", s3_path_prefix = "") {
  .latest_bps_vintage(s3_bucket, s3_path_prefix)
}
