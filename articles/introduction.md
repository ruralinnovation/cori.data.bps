# Introduction to cori.data.bps

`cori.data.bps` provides annual building permit data from the U.S.
Census Bureau’s Building Permits Survey (BPS). Data cover 2000–present
and measure new residential units authorized by building permits across
all structure types.

**Source:** U.S. Census Bureau, Building Permits Survey **Coverage:**
2000–present, updated annually (release typically May) **Geography:**
County (5-digit FIPS), state (2-digit FIPS), national (`"00"`)

## Variables

``` r

library(cori.data.bps)

get_bps_codebook() |>
  dplyr::select(variable, label, unit, notes) |>
  gt::gt() |>
  gt::cols_label(
    variable = "Variable",
    label    = "Label",
    unit     = "Unit",
    notes    = "Notes"
  )
```

| Variable | Label | Unit | Notes |
|----|----|----|----|
| building_permits | New residential units authorized | units | Total new residential units authorized by building permits (all structure types). Sum of single-family, 2-family, 3-to-4-family, and 5-plus-family units. Coverage: 2000-present. Geography: county (5-digit FIPS), state (2-digit FIPS), national ('00'). |
| units_per_1k_people | New residential units authorized per 1,000 population | units per 1,000 persons | Total new residential units authorized divided by resident population in thousands. Population denominator from Census Population Estimates Program via cori.data.pep. agg_var = population / 1,000, suitable for population-weighted averaging. Coverage: 2000-present. Geography: county (5-digit FIPS), state (2-digit FIPS), national ('00'). |

## Reading data

All data are returned in long format: one row per
`geoid / year / variable`.

``` r

df <- get_building_permits(geography = "county")

dplyr::glimpse(df)
```

Filter to specific variables, years, or geographies:

``` r

# New Hampshire counties, permits per 1k population, 2010 onward
nh_bps <- get_building_permits(
  variables = "units_per_1k_people",
  geoids    = grep("^33", unique(df$geoid), value = TRUE),
  years     = 2010:2024
)

dplyr::glimpse(nh_bps)
```

## Rural vs. Nonrural

Housing permit activity diverges between rural and nonrural counties.
The chart below shows population-weighted average units permitted per
1,000 people by rural status using the CBSA 2023 rural definition.

``` r

library(cori.charts)
library(ggplot2)
library(ruraldefinitions)
library(dplyr)

load_fonts()

rural_avg <- df |>
  filter(variable == "units_per_1k_people") |>
  left_join(select(cbsa_2023, geoid, is_rural), by = "geoid") |>
  filter(!is.na(is_rural), !is.na(value), !is.na(agg_var)) |>
  group_by(year, is_rural) |>
  summarise(
    value = sum(value * agg_var, na.rm = TRUE) / sum(agg_var, na.rm = TRUE),
    .groups = "drop"
  )

ggplot(rural_avg, aes(x = year, y = value, color = is_rural)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_manual(
    values = c("Rural" = "#2F6E9B", "Nonrural" = "#7EBDC2"),
    labels = c("Rural" = "Rural counties", "Nonrural" = "Nonrural counties")
  ) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 5)) +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.1)) +
  theme_cori() +
  theme(legend.position = "bottom") +
  labs(
    title    = "Nonrural counties consistently authorize more housing per capita",
    subtitle = "New residential units authorized per 1,000 population, 2000\u20132024",
    x        = NULL,
    y        = NULL,
    color    = NULL,
    caption  = "Source: CORI analysis of U.S. Census Bureau Building Permits Survey."
  )
```

## County Spotlight: Grafton County, NH

``` r

grafton <- get_building_permits(
  variables = "units_per_1k_people",
  geoids    = c("33009", "33", "00")
) |>
  mutate(
    group = case_when(
      geoid == "33009" ~ "Grafton County, NH",
      geoid == "33"    ~ "New Hampshire",
      geoid == "00"    ~ "United States"
    ),
    group = factor(group, levels = c("Grafton County, NH", "New Hampshire", "United States"))
  )

ggplot(grafton, aes(x = year, y = value, color = group, linetype = group, linewidth = group)) +
  geom_line(na.rm = TRUE) +
  geom_point(size = 2.5, na.rm = TRUE) +
  scale_color_manual(values = c(
    "Grafton County, NH" = "#2F6E9B",
    "New Hampshire"      = "#7EBDC2",
    "United States"      = "#9DA7B0"
  )) +
  scale_linetype_manual(values = c(
    "Grafton County, NH" = "solid",
    "New Hampshire"      = "dashed",
    "United States"      = "dotted"
  )) +
  scale_linewidth_manual(values = c(
    "Grafton County, NH" = 1.2,
    "New Hampshire"      = 0.8,
    "United States"      = 0.8
  )) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 5)) +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.1)) +
  theme_cori() +
  theme(legend.position = "bottom") +
  labs(
    title    = "Grafton County, NH\nNew residential units authorized per 1,000 residents",
    subtitle = "Compared to New Hampshire and the United States, 2000\u20132024",
    x        = NULL,
    y        = NULL,
    color    = NULL,
    linetype = NULL,
    linewidth = NULL,
    caption  = paste0(
      "Source: CORI analysis of U.S. Census Bureau Building Permits Survey.\n",
      "Population denominator from Census Population Estimates Program via cori.data.pep."
    )
  )
```
