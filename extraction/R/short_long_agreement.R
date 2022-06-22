# Cohen's Kappa agreement of the manual analysis
# on the expected lifetime of toggles living longer
# than most.

library(psych)
library(readxl)
library(dplyr)

short_long <- read_excel("analysis/short_long.xlsx", 
                         sheet = "short_long")

longer <- short_long %>%
  filter(
    all_routers_removed == "false",
    weeks_survived > 49
  ) %>%
  rename(
    author_1 = expected_longevity,
    author_2 = `Rabe expected longevity`
  ) %>%
  select(
    author_1,
    author_2
  )

#data may be explicitly categorical
# x <- c("red","yellow","blue","red")
# y <- c("red",  "blue", "blue" ,"red") 
longer.df <- data.frame(longer$author_1, longer$author_2)
ck <- cohen.kappa(longer.df)
ck
ck$agree
