# Get the cori.data.bps variable codebook

Returns a data frame describing each variable available from
\[get_building_permits()\].

## Usage

``` r
get_bps_codebook()
```

## Value

A data frame with columns: \`variable\`, \`raw_variable\`, \`label\`,
\`unit\`, \`nominal\`, \`notes\`. \`raw_variable\` is the original name
stored in S3 parquet files.

## See also

\[get_building_permits()\]

## Examples

``` r
get_bps_codebook()
#>              variable        raw_variable
#> 1    building_permits    building_permits
#> 2 units_per_1k_people units_per_1k_people
#>                                                   label                    unit
#> 1                      New residential units authorized                   units
#> 2 New residential units authorized per 1,000 population units per 1,000 persons
#>   nominal
#> 1    TRUE
#> 2   FALSE
#>                                                                                                                                                                                                                                                                                                                                               notes
#> 1                                                                                        Total new residential units authorized by building permits (all structure types). Sum of single-family, 2-family, 3-to-4-family, and 5-plus-family units. Coverage: 2000-present. Geography: county (5-digit FIPS), state (2-digit FIPS), national ('00').
#> 2 Total new residential units authorized divided by resident population in thousands. Population denominator from Census Population Estimates Program via cori.data.pep. agg_var = population / 1,000, suitable for population-weighted averaging. Coverage: 2000-present. Geography: county (5-digit FIPS), state (2-digit FIPS), national ('00').
```
