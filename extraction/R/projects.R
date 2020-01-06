library(readr)
library(magrittr)
library(dplyr)

all_projects <- read_csv('analysis/merged/operations-per-type.csv')

filtered_projects <- all_projects %>%
  mutate(
    router_ops = `ADDED-Router` + `MODIFIED-Router` + `DELETED-Router`,
    point_ops = `ADDED-Point` + `MODIFIED-Point` + `DELETED-Point`
  ) %>%
  filter(
    # num_toggles_aprox >= 10,
    router_ops > 10,
    # router_ops >= 10 | point_ops >= 10,
  )

filtered_projects <- all_projects

projects <- filtered_projects$repo_name