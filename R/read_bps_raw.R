#' Read raw BPS data from Census Bureau for a single year
#'
#' Fetches county and state Building Permits Survey text files directly from
#' the Census Bureau and returns a combined wide-format data frame. National
#' totals are computed as the sum across the 50 states and DC.
#'
#' @param year Integer. Year to read.
#'
#' @return A data frame with columns: \code{geoid}, \code{year},
#'   \code{single_family_units}, \code{units_2_family},
#'   \code{units_3_to_4_family}, \code{units_5_plus_family}.
#'
#' @keywords internal
#' @export
read_bps_raw <- function(year) {

  old_timeout <- getOption("timeout")
  on.exit(options(timeout = old_timeout), add = TRUE)
  options(timeout = 600)

  # --- County ---
  county_url <- sprintf(
    "https://www2.census.gov/econ/bps/County/co%da.txt", year
  )
  message(sprintf("Reading BPS county data: %d...", year))
  county_raw <- utils::read.delim(
    url(county_url), header = TRUE, sep = ",", row.names = NULL, skip = 1
  )

  county <- county_raw |>
    dplyr::select(
      state               = "State",
      county              = "County",
      single_family_units = "Units",
      units_2_family      = "Units.1",
      units_3_to_4_family = "Units.2",
      units_5_plus_family = "Units.3"
    ) |>
    dplyr::filter(!is.na(county), county != 0) |>
    dplyr::mutate(
      state  = stringr::str_pad(as.character(state),  width = 2, side = "left", pad = "0"),
      county = stringr::str_pad(as.character(county), width = 3, side = "left", pad = "0"),
      geoid  = paste0(state, county),
      geoid  = dplyr::if_else(geoid == "02270", "02158", geoid),
      year   = as.integer(year)
    ) |>
    dplyr::select(
      geoid, year,
      single_family_units, units_2_family, units_3_to_4_family, units_5_plus_family
    )

  # --- State ---
  state_url <- sprintf(
    "https://www2.census.gov/econ/bps/State/st%da.txt", year
  )
  message(sprintf("Reading BPS state data: %d...", year))
  state_raw <- utils::read.delim(
    url(state_url), header = TRUE, sep = ",", row.names = NULL, skip = 1
  )

  state <- state_raw |>
    dplyr::filter(Name %in% c(datasets::state.name, "District of Columbia")) |>
    dplyr::select(
      geoid               = "State",
      single_family_units = "Units",
      units_2_family      = "Units.1",
      units_3_to_4_family = "Units.2",
      units_5_plus_family = "Units.3"
    ) |>
    dplyr::mutate(
      geoid = stringr::str_pad(as.character(geoid), width = 2, side = "left", pad = "0"),
      year  = as.integer(year)
    ) |>
    dplyr::select(
      geoid, year,
      single_family_units, units_2_family, units_3_to_4_family, units_5_plus_family
    )

  # --- National: sum of 50 states + DC ---
  national <- state |>
    dplyr::summarise(
      dplyr::across(
        c(single_family_units, units_2_family, units_3_to_4_family, units_5_plus_family),
        ~sum(.x, na.rm = TRUE)
      )
    ) |>
    dplyr::mutate(geoid = "00", year = as.integer(year)) |>
    dplyr::select(
      geoid, year,
      single_family_units, units_2_family, units_3_to_4_family, units_5_plus_family
    )

  dplyr::bind_rows(county, state, national)
}
