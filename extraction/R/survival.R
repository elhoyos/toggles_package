library(survival)
library(effsize)
library(readr)
library(beanplot)
library(magrittr)
library(dplyr)
library(xtable)
library(tidyr)

options(
  warn=2, # Exit if a warning
  stringsAsFactors=FALSE # Do not convert strings to factors when loading csv files
)

source("./R/get_stable_point.R")
source("./R/projects.R")
source("./R/commons.R")

SECONDS = 86400 * 7 # Each week
stabilization_delta = 0.01
base_path <- "./analysis/raw/"
as_filenames <- function(projects_as_repos) {
  return(sub("/", "__", projects_as_repos))
}

paths <- paste(base_path, as_filenames(projects), sep="")
filenames = dir(pattern="^survival.csv$", path = paths, full.names = TRUE, recursive = TRUE)

# Colors
col = 1:4

# Full set
pdf(paste("figure_survival_all_projects.pdf", sep=""), width=6.83, height=5)
par(mfrow = c(3, 4), mar=c(2.5,2,1.5,2), oma=c(0,0,3,0))

all_points <- tibble()
all_routers <- tibble()
for (i in 1:length(filenames)) {
  data <- read.csv(filenames[i]) %>%
    filter(toggle_type == "Point") %>%
    mutate(weeks_survived = ceiling(epoch_interval/SECONDS)) %>%
    group_by(repo_name, original_id) %>%
    summarize(weeks_survived = max(weeks_survived), removed = max(removed))

  data_routers <- read.csv(filenames[i]) %>%
    filter(toggle_type == "Router") %>%
    mutate(weeks_survived = ceiling(epoch_interval/SECONDS)) %>%
    group_by(repo_name, original_id) %>%
    summarize(weeks_survived = max(weeks_survived), removed = max(removed))

  all_points <- union_all(all_points, data)
  all_routers <- union_all(all_routers, data_routers)
  repo_name <- data$repo_name[1]
  print(repo_name)

  kmsurvival <- survfit(Surv(ceiling(data$weeks_survived), data$removed) ~ 1)
  print(summary(kmsurvival))

  plot(kmsurvival, col=col)
  title(main=no_org(repo_name), mgp=c(2.5, 0, 0), cex.lab=1.2, cex.main=1)
  box(lwd=1.95)
}

# How different are the weeks survived for points and toggles?
wilcox.test(all_points$weeks_survived,all_routers$weeks_survived)
cliff.delta(all_points$weeks_survived,all_routers$weeks_survived)

par(fig = c(0, 1, 0, 1),
    oma = c(0, 0, 0, 0),
    mar = c(0.1, 0, 0, 0.1),
    new = TRUE)
plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
legend("top",
       legend = c("Esimate", "Lower 95%", "Upper 95%"),
       col = col,
       xpd = TRUE,
       horiz = TRUE,
       inset = c(0, 0),
       lty = 1,
       cex = 0.8)

dev.off()

summary(all_points$weeks_survived)

pdf("figure_points_weeks_survived.pdf", width=2.5, height=4)
par(mar=c(0.5, 4, 0.5, 0.6))
beanplot(all_points$weeks_survived, overallline = "median", ll = 0)
mtext("Weeks survived", side = 2, line = 2.5)
dev.off()

# how many components remain after the 3rd quartile?
third_q <- quantile(all_points$weeks_survived, names = TRUE)["75%"]
points_by_repo <- all_points %>% group_by(repo_name) %>% summarize(n_points = n())
removed_after_3rdQ <- all_points %>%
  left_join(points_by_repo, by = "repo_name") %>%
  group_by(repo_name) %>%
  summarize(n = sum(weeks_survived > third_q), n_points = max(n_points)) %>%
  mutate(ratio = n/n_points)

# how many sampled short/long toggles' survived weeks deviate from the 3rd quartile and the project's own median?
local_medians <- all_points %>%
  group_by(repo_name) %>%
  summarize(local_median = median(weeks_survived))

expected_weeks <- tribble(
  ~repo_name,                    ~expected_weeks_short,
  "mozilla/zamboni",              4,
  "edx/ecommerce",                12,
  "edx/course-discovery",         12,
  "uclouvain/osis",               2,
  "edx/edx-platform",             12,
  "edx/edx-analytics-dashboard",  12,
  "mozilla/kitsune",              NA,
  "CenterForOpenScience/osf.io",  2,
  "kh-004-webuipython/Jiller",    NA,
  "ccnmtl/wardenclyffe",          NA,
  "tndatacommons/tndata_backend", NA,
  "mozilla/bedrock",              NA
)

short_long_toggles <- read.csv("./analyze/short_long.csv")

short_term_toggles <- short_long_toggles %>%
  left_join(expected_weeks, by = "repo_name") %>%
  filter(
    expected_longevity == "short",
    !is.na(expected_weeks_short),
  ) %>%
  mutate(
    diff_real_expected = weeks_survived - expected_weeks_short,
  ) %>%
  group_by(repo_name, expected_longevity) %>%
  summarize(
    n = n(),
    n_remaining = sum(all_routers_removed == "false"),
    real_lte_expected_weeks = as.integer(sum(-1 * diff_real_expected[diff_real_expected <= 0])),
    real_gt_expected_weeks = as.integer(sum(diff_real_expected[diff_real_expected > 0])),
  ) %>%
  ungroup() %>%
  mutate(
    no_org_repo_name = no_org(repo_name),
  ) %>%
  select(
    "Project" = no_org_repo_name,
    "Sample" = n,
    "Remaining" = n_remaining,
    "SumWeeks(<= expected)" = real_lte_expected_weeks,
    "SumWeeks(> expected)" = real_gt_expected_weeks,
  )

print(xtable(
  short_term_toggles,
  type = "latex",
), file = "short_term_toggles.tex")
