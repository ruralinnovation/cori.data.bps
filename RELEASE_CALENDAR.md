# Release Calendar — cori.data.bps

## Source Information

| Field | Detail |
|---|---|
| **Full name** | U.S. Census Bureau Building Permits Survey (BPS) |
| **Producer** | U.S. Census Bureau, Economic Indicators Division |
| **Program page** | https://www.census.gov/construction/bps/ |
| **Release schedule** | https://www.census.gov/construction/bps/schedule.html |
| **Coverage** | County, state, national · 2000–present · Annual release each May |

## Release Cadence

The BPS publishes data in two tiers each month:

- **Preliminary** (12th workday, 8:30 a.m.): U.S. and regional totals only
- **Revised** (17th workday, 8:00 a.m.): Full county, state, metro, and place detail

Annual benchmarked data for the prior year is released each May. The county
annual files used by this package follow the pattern:
- County: `https://www2.census.gov/econ/bps/County/co{YYYY}a.txt`
- State: `https://www2.census.gov/econ/bps/State/st{YYYY}a.txt`

## Vintage Log

| Vintage | Data covers | Captured | By | S3 path |
|---|---|---|---|---|
| 2025 | 2000–2025 | 2026-06-03 | Drew | `s3://cori.data.bps/data_processed/vintage_2025/` |
| 2024 | 2000–2024 | 2026-04-16 | Drew | `s3://cori.data.bps/data_processed/vintage_2024/` |

## Next Capture

| Field | Detail |
|---|---|
| **Expected release** | May 2027 (2026 annual data) |
| **Responsible** | Drew Rosebush |
| **Notes** | Run `write_bps_to_s3(years = 2000:2026)` after release |
