utils::globalVariables(c(
  # Identifiers
  "geoid", "year",

  # Raw BPS column names (before renaming in dplyr::select)
  "State", "County", "Name",

  # Renamed / derived columns
  "state", "county",
  "single_family_units", "units_2_family",
  "units_3_to_4_family", "units_5_plus_family",
  "total_units",

  # Population join
  "pop",

  # Five-column tidy contract
  "variable", "value", "agg_var"
))
