library(readr)
library(magrittr)
library(dplyr)

all_projects <- read_csv('analysis/merged/rqX-operations-per-type.csv')

filtered_projects <- all_projects %>%
  filter(num_toggles_aprox >= 10)

# filtered_projects <- all_projects

projects <- filtered_projects$repo_name