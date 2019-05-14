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

pdf("deteled_vs_number_vs_commits.pdf", width=5, height=4)
par(mfrow=c(2, 3))
boxplot(ratios$del_routers_ratio, horizontal = FALSE, ylab="% Deleted Routers")
plot(ratios$num_toggles_aprox, ratios$del_routers_ratio, ylab="", xlab="Toggles")
plot(ratios$number_of_commits, ratios$del_routers_ratio, ylab="", xlab="Commits")
boxplot(ratios$del_points_ratio, horizontal = FALSE, ylab="% Deleted Points")
plot(ratios$num_toggles_aprox, ratios$del_points_ratio, ylab="", xlab="Toggles")
plot(ratios$number_of_commits, ratios$del_points_ratio, ylab="", xlab="Commits")
dev.off()

plot(ratios$number_of_commits, ratios$num_toggles_aprox, main="#Toggles vs #Commits")

# Minum removal cap in number of toggles
ratios %>% filter(num_toggles_aprox > 4) %>% summarize(min(del_routers_ratio), min(del_points_ratio), n())

# Large projects
ratios %>% filter(number_of_commits > 10000) %>% summarize(n())

