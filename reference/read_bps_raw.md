# Read raw BPS data from Census Bureau for a single year

Fetches county and state Building Permits Survey text files directly
from the Census Bureau and returns a combined wide-format data frame.
National totals are computed as the sum across the 50 states and DC.

## Usage

``` r
read_bps_raw(year)
```

## Arguments

- year:

  Integer. Year to read.

## Value

A data frame with columns: `geoid`, `year`, `single_family_units`,
`units_2_family`, `units_3_to_4_family`, `units_5_plus_family`.
