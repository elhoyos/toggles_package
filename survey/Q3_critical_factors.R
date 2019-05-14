library(readxl)
library(dplyr)
library(tidyr)
library(purrr)

toggles_intro_reasons <- read_excel("./results/Toggle Debt survey_merged_201901161456.xlsx", 
                                    sheet = "Toggle Debt survey_merged", 
                                    range = "D2:D62",
                                    col_names = c("reasons"))

names <- data.frame(
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

separator = ";"

reasons <- toggles_intro_reasons %>%
  mutate(reasons = sapply(reasons, function(reasonlist) {
    # rename, it is easier to analyze shorter texts
    reasons <- sort(unlist(strsplit(reasonlist, separator)))
    return(paste(names$short[match(reasons, names$long, nomatch = length(names$short))], collapse = separator))
  }))

# split into different fields for each row
# Following https://stackoverflow.com/a/43809205/638425
res <- lapply(reasons$reasons, function(x) {
  split <- strsplit(x, separator, fixed = TRUE)
  names <- unlist(split)
  values <- as.list(rep(1, length(names)))

  setNames(values, names)
})

splitted_reasons <- bind_rows(res)

combinations <- splitted_reasons %>%
  group_by_all() %>%
  summarise(count = n())

combinations$nresponses <- rowSums(combinations[,-length(colnames(combinations))], na.rm = TRUE)
summary(combinations$nresponses)

ocurrences <- splitted_reasons %>%
  summarise_all(sum, na.rm = TRUE)

# most popular combination
bs <- combinations[which.max(combinations$count),]
count = bs$count
bs$count = NULL
bs$nresponses = NULL

# factors probability
counts <- sapply(bs, function (x) {
  if (!is.na(x)) {
    return(x * count)
  }
  return(NA)
})
counts <- counts[!is.na(counts)]

fn <- function (count, name) {
  return(count/ocurrences[name])
}

prob <- Map(fn, counts, names(counts))

