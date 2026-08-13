# Get Building Permits Survey data

Queries CORI's processed Building Permits Survey (BPS) parquet files
from S3 using DuckDB. Returns long-format data: one row per \`geoid /
year / variable\`.

## Usage

``` r
get_building_permits(
  geography = c("county", "state", "nation"),
  years = NULL,
  geoids = NULL,
  variables = NULL,
  vintage = "latest"
)
```

## Arguments

- geography:

  Character. One of \`"all"\`, \`"county"\`, \`"state"\`, or
  \`"nation"\`. Filters rows by geography level. Default: \`"all"\`.

- years:

  Integer vector. Years to return. Default: all available.

- geoids:

  Character vector. FIPS codes to return (5-digit county, 2-digit state,
  or \`"00"\` for national). When supplied, overrides \`geography\`.
  Default: all.

- variables:

  Character vector. Variables to return. Default: all. See
  \[get_bps_codebook()\] for valid names.

- vintage:

  Character. Vintage to read, e.g. \`"2024"\`. Default: \`"latest"\`,
  which reads the \`\_LATEST\` pointer written by \`write_bps_to_s3()\`.

## Value

A data frame with columns: \`geoid\`, \`year\`, \`variable\`, \`value\`,
\`agg_var\`. \`agg_var\` is population / 1,000, suitable for
population-weighted averaging of \`units_per_1k_people\`.

## See also

\[get_bps_codebook()\]

## Examples

``` r
if (FALSE) { # \dontrun{
get_building_permits(geography = "county")
get_building_permits(geography = "county", years = 2010:2024)
get_building_permits(geoids = c("33009", "33", "00"))
} # }
```
