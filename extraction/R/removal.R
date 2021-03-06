library(readr)
library(effsize)
library(magrittr)
library(dplyr)
library(tidyr)
library(beanplot)

source("./R/projects.R")

data <- read_csv('analysis/merged/operations-per-type.csv')
repos <- read_csv('analysis/waffle_projects.csv')

ratios <- data %>%
  mutate(
    router_ops = `ADDED-Router` + `MODIFIED-Router` + `DELETED-Router`,
    point_ops = `ADDED-Point` + `MODIFIED-Point` + `DELETED-Point`
  ) %>%
  filter(repo_name %in% projects) %>%
  left_join(repos) %>%
  mutate(
    points = `ADDED-Point`,
    routers = `ADDED-Router`,
    remaining_points = `ADDED-Point` - `DELETED-Point`,
    remaining_routers = `ADDED-Router` - `DELETED-Router`,
    remaining_diff = remaining_routers - remaining_points,
    remaining_ratio = replace_na(remaining_routers / remaining_points, 1),
    del_points = `DELETED-Point`,
    del_routers = `DELETED-Router`,
    del_points_ratio = replace_na(del_points/`ADDED-Point`, 0),
    del_routers_ratio = replace_na(del_routers/`ADDED-Router`, 0)
  ) %>%
  select(
    repo_name,
    num_toggles_aprox,
    router_ops,
    point_ops,
    number_of_commits,
    routers,
    remaining_routers,
    points,
    remaining_points,
    remaining_diff,
    remaining_ratio,
    del_points,
    del_routers,
    del_points_ratio,
    del_routers_ratio
  )

# How different are ratios of Routers and Points?
# Disable wilcox test temporarily (warning erroring)
wilcox.test(ratios$del_routers,ratios$del_points, exact = FALSE)
cliff.delta(ratios$del_routers,ratios$del_points)

summary(ratios$num_toggles_aprox)
# boxplot(ratios$num_toggles_aprox, horizontal = TRUE)
# title("Number of toggles (aprox.)")
pdf("figure_hist_num_toggles_approx_72_projects.pdf", width=4, height=2.5)
par(mfrow=c(1, 1), mar=c(4, 4, 1, 1))
hist(
  ratios$num_toggles_aprox,
  breaks = 80,
  ylim = range(0, 40),
  main = NULL,
  xlab = "Number of toggles (approximate)")
dev.off()
# plot(density(ratios$num_toggles_aprox), main="Number of toggles Distribution")

par(mfrow=c(2, 1))
hist(ratios$router_ops, breaks=15, main="Number of Router operations")
hist(ratios$point_ops, breaks=15, main="Number of Points operations")

summary(ratios$number_of_commits)
boxplot(ratios$number_of_commits, horizontal = TRUE)
title("Number of commits")
# Projects with more Routers deleted
more_routers_deleted = ratios %>% filter(remaining_diff < 0) %>% arrange(desc(remaining_diff))
more_routers_deleted
summary(more_routers_deleted$remaining_diff)

# Projects with more Points deleted
# Use the following jq script to go through these Routers:
# node analyze/analyzers/living-routers-without-point.js analysis/raw/edx__course-discovery/edx__course-discovery.json | jq -C '. | map({ id: .toggle.id, operation: .operation, link: "https://github.com/edx/course-discovery/blob/\(.commit.commit)/\(.toggle.file)#L\(.toggle.start.line)"}) | flatten'
more_points_deleted <- ratios %>% filter(remaining_diff > 0) %>% arrange(desc(remaining_ratio))
summary(more_points_deleted$remaining_ratio)
beanplot(more_points_deleted$remaining_ratio, beanlines = "quantiles")


# Number of routers per point
ratio_added_components <- ratios %>%
  mutate(routers_per_point = routers/points) %>%
  select(repo_name, routers_per_point, remaining_ratio)

summary(ratio_added_components)
par(mfrow=c(1, 1))
beanplot(ratio_added_components$routers_per_point, beanlines = "quantiles")

# Projects with 100% removal
ratios %>% filter(del_routers_ratio == 1 & del_points_ratio == 1)

# Projects not removing both components
ratios %>% filter(del_routers_ratio == 0 & del_points_ratio == 0)

# Projects with same amount of deleted components but not 0% or 100% on each type
ratios %>% filter(remaining_diff == 0 & del_points_ratio > 0 & del_points_ratio < 1)

summary(ratios$del_points_ratio)
summary(ratios$del_routers_ratio)

del_routers_ratio <- ratios %>%
  mutate(component = "Routers") %>%
  select(
    repo_name,
    component,
    ratio = del_routers_ratio)
del_points_ratio <- ratios %>%
  mutate(component = "Points") %>%
  select(
    repo_name,
    component,
    ratio = del_points_ratio)
joined_ratios <- union_all(del_routers_ratio, del_points_ratio) %>%
  arrange(!is.na(component))

# pdf("figure_removed_ratio_by_component.pdf", width=2.5, height=4)
# par(mar=c(3, 4, 0.5, 0.6))
# boxplot(joined_ratios$ratio ~ joined_ratios$component,
#         horizontal = FALSE,
#         xlab = "",
#         ann = FALSE,
#         col = "grey")
# mtext("% removed components", side = 2, line = 2.5)
# dev.off()

summary(del_points_ratio$ratio)

pdf("figure_removed_points_ratio.pdf", width=2.5, height=4)
par(mar=c(0.5, 4, 0.5, 0.6))
beanplot(del_points_ratio$ratio)
mtext("% removed components", side = 2, line = 2.5)
dev.off()

hist(del_points_ratio$ratio, breaks = 12)
plot(density(del_points_ratio$ratio, bw = "SJ"))

pdf("figure_removed_ratio_by_toggles_commits.pdf", width=6, height=3.2)
ratio_range <- range(c(ratios$del_routers_ratio, ratios$del_points_ratio))
min_ratio <- min(ratio_range)
max_ratio <- max(ratio_range)

toggles_range <- range(ratios$num_toggles_aprox)
min_toggles <- min(toggles_range)
max_toggles <- max(toggles_range)

commits_range <- range(ratios$number_of_commits)
min_commits <- min(commits_range)
max_commits <- max(commits_range)

par(mfcol=c(1, 2))
par(mar=c(0, 0, 0, 0), oma=c(5, 4, 0.5, 1))

plot(toggles_range,
     ratio_range,
     type = 'n',
     axes = FALSE,
     ann = FALSE)
axis(1, at = seq(0, max_toggles, by = 10))
axis(2, at = seq(min_ratio, max_ratio, by = 0.2))
mtext("Toggles (approx.)", side = 1, line = 3)
mtext("% removed components", side = 2, line = 3)
box()
points(ratios$num_toggles_aprox,
     ratios$del_routers_ratio,
     pch = 1)
points(ratios$num_toggles_aprox,
     ratios$del_points_ratio,
     pch = 3)

plot(commits_range,
     ratio_range,
     type = 'n',
     axes = FALSE,
     ann = FALSE)
axis(1, at = seq(0, 52000, by = 10000))
mtext("Commits", side = 1, line = 3)
box()
points(ratios$number_of_commits,
       ratios$del_routers_ratio,
       pch = 1)
points(ratios$number_of_commits,
       ratios$del_points_ratio,
       pch = 3)

# Overlay a blank plot to create a legend
# Borrowed from https://dr-k-lo.blogspot.com/2014/03/the-simplest-way-to-plot-legend-outside.html
par(fig = c(0, 1, 0, 1),
    oma = c(0, 0, 0, 0),
    mar = c(0.1, 0, 0, 0.1),
    new = TRUE)
plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
legend("bottomright",
       legend=c("Routers","Points"),
       xpd = TRUE,
       horiz = FALSE,
       inset = c(0, 0),
       pch = c(1, 3),
       cex = 0.8)
dev.off()

plot(ratios$number_of_commits, ratios$num_toggles_aprox, main="#Toggles vs #Commits")

# Minum removal cap in number of toggles
ratios %>% filter(num_toggles_aprox > 4) %>% summarize(min(del_routers_ratio), min(del_points_ratio), n())

# Large projects
ratios %>% filter(number_of_commits > 10000) %>% summarize(n())

