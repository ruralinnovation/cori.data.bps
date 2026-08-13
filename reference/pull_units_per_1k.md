# Pull BPS processed variables

Reads raw BPS data from the Census Bureau for the requested years, joins
with a population data frame, and returns the five-column tidy format
for both \`building_permits\` and \`units_per_1k_people\`.

## Usage

``` r
pull_units_per_1k(years, pop_df)
```

## Arguments

- years:

  Integer vector. Years to pull.

- pop_df:

  Data frame with columns `geoid`, `year`, `pop`.

## Value

A data frame: `geoid`, `year`, `variable`, `value`, `agg_var`.
