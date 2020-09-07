Mix: experience, position and usage of feature toggles
================

This analysis combines the experience, position and usage of feature
toggles reported by the survey participants.

``` r
library(readr)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(tidyr)
library(ggplot2)
```

``` r
usages_names <- data.frame(
  "long" = c(
    "Trunk-based development / WIP",
    "A/B or Mutivariate Testing",
    "Canary Releases",
    "Dark Launches",
    "Kill Switch",
    "Blue-green Deployments",
    NA
  ),
  "short" = c(
    "Trunk-based",
    "A/B",
    "Canary",
    "Dark",
    "Kill",
    "Blue-green",
    "Other"
  ))

positions_names <- data.frame(
  "long" = c(
    "Software Engineer / Developer",
    "Software Architect",
    "CTO",
    NA
  ),
  "short" = c(
    "Software Engineer / Developer",
    "Software Architect",
    "CTO",
    "Other"
  ))

separator <- ";"

renameme <- function(list, names) {
  # rename, it is easier to analyze shorter texts
  reasons <- sort(unlist(strsplit(list, separator)))
  return(paste(names$short[match(reasons, names$long, nomatch = length(names$short))], collapse = separator))
}

as.usages <- function(usages) {
  return(renameme(usages, usages_names))
}

as.position <- function(positions) {
  return(renameme(positions, positions_names))
}

data <- read_csv("./results/Toggle Debt survey_merged_201901161456.csv",) %>%
  mutate(
    respondent = row_number(),
    experience = `How many years of professional experience do you have?`,
    position = sapply(`How would you best describe your profession?`, as.position),
    usages = sapply(`When/for what reason do you introduce toggles in your project?`, as.usages),
  ) %>%
  dplyr::select(
    respondent,
    experience,
    position,
    usages,
  ) %>%
  separate_rows(usages, sep = ";")
```

    ## Parsed with column specification:
    ## cols(
    ##   Timestamp = col_character(),
    ##   `How would you best describe your profession?` = col_character(),
    ##   `How many years of professional experience do you have?` = col_character(),
    ##   `When/for what reason do you introduce toggles in your project?` = col_character(),
    ##   `Do you ever remove features toggles? If so, why/when do you remove these feature toggles?` = col_character(),
    ##   `Do you ever face toggle debt (e.g. mistakenly activating a WIP feature in production)? If so, how do you manage such toggle debt?` = col_character(),
    ##   `If you would like to receive the results of our research, please provide us with your email address` = col_character(),
    ##   `Would be available for a possible ~10 mins follow-up interview? (We will contact you at a later time to schedule the meeting)` = col_character()
    ## )

### Heatmap

We have 3 variables, let’s give a try to a heatmap:

``` r
heatmap_data <- data %>%
  group_by(respondent, position, usages) %>%
  summarize(
    experience_scaled = case_when(
      experience == "Between 1 and 3 Years" ~ 1,
      experience == "Between 4 and 5 Years" ~ 2,
      experience == "More than 5 Years" ~ 3,
      TRUE ~ -1 # Bang!
    ),
  )

ggplot(heatmap_data, aes(usages, position, fill = experience_scaled)) +
  geom_tile()
```

![](mix_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

Heatmaps are not quite the way to go here. Seems like heatmaps are made
for non-categorical/discrete variables.

### Multiple Correspondence Analysis

PCA or Principal Component Analysis apparently can be used for
categorical variables: <https://stats.stackexchange.com/a/5777/244050>

TODO: Something to try

### 3-way table
