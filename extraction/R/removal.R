library(readr)
library(effsize)
library(magrittr)
library(dplyr)

data <- read_csv('analysis/merged/rqX-operations-per-type.csv')
repos <- read_csv('analysis/waffle_repositories.csv')

# How different are ratios of Routers and Points?
# Disable wilcox test temporarily (warning erroring)
# wilcox.test(data$"DELETED-Router",data$"DELETED-Point")
cliff.delta(data$"DELETED-Router",data$"DELETED-Point")

ratios <- data %>%
  left_join(repos) %>%
  mutate(
    points = `ADDED-Point`,
    routers = `ADDED-Router`,
    remaining_points = `ADDED-Point` - `DELETED-Point`,
    remaining_routers = `ADDED-Router` - `DELETED-Router`,
    remaining_diff = remaining_routers - remaining_points,
    remaining_ratio = if_else(remaining_points == 0, 1, remaining_routers / remaining_points),
    del_points_ratio = `DELETED-Point`/`ADDED-Point`,
    del_routers_ratio = `DELETED-Router`/`ADDED-Router`
  ) %>%
  select(
    repo_name,
    num_toggles_aprox,
    number_of_commits,
    routers,
    remaining_routers,
    points,
    remaining_points,
    remaining_diff,
    remaining_ratio,
    del_points_ratio,
    del_routers_ratio
  )

par(mfrow=c(2, 1))
summary(ratios$num_toggles_aprox)
boxplot(ratios$num_toggles_aprox, horizontal = TRUE)
title("Number of toggles (aprox.)")

summary(ratios$number_of_commits)
boxplot(ratios$number_of_commits, horizontal = TRUE)
title("Number of commits")

# Projects with more Routers deleted
more_routers_deleted = ratios %>% filter(remaining_diff < 0) %>% arrange(desc(remaining_diff))
more_routers_deleted
summary(more_routers_deleted$remaining_diff)

# Projects with more Points deleted
more_points_deleted = ratios %>% filter(remaining_diff > 0) %>% arrange(desc(remaining_ratio))
more_points_deleted
summary(more_points_deleted$remaining_ratio)

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
    component,
    ratio = del_routers_ratio)
del_points_ratio <- ratios %>%
  mutate(component = "Points") %>%
  select(
    component,
    ratio = del_points_ratio)
joined_ratios <- union_all(del_routers_ratio, del_points_ratio) %>%
  arrange(!is.na(component))

pdf("figure_removed_ratio_by_component.pdf", width=2.5, height=4)
par(mar=c(3, 4, 0.5, 0.6))
boxplot(joined_ratios$ratio ~ joined_ratios$component,
        horizontal = FALSE,
        xlab = "",
        ann = FALSE,
        col = "grey")
mtext("% removed components", side = 2, line = 2.5)
dev.off()

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

