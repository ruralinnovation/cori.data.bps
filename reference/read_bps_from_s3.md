# Read processed BPS data from S3

\`r lifecycle::badge("deprecated")\`

\`read_bps_from_s3()\` is deprecated. Use \[get_building_permits()\]
instead.

## Usage

``` r
read_bps_from_s3(
  vintage = "latest",
  variables = NULL,
  years = NULL,
  geoids = NULL,
  s3_bucket = "cori.data.bps",
  s3_path_prefix = ""
)
```

## Arguments

- vintage:

  Passed to \[get_building_permits()\].

- variables:

  Passed to \[get_building_permits()\].

- years:

  Passed to \[get_building_permits()\].

- geoids:

  Passed to \[get_building_permits()\].

- s3_bucket:

  Ignored. No longer configurable in the public API.

- s3_path_prefix:

  Ignored. No longer configurable in the public API.

## Value

A data frame. See \[get_building_permits()\] for details.

## See also

\[get_building_permits()\]
