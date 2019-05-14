library(readr)
library("magrittr", lib.loc="/usr/local/lib/R/3.3/site-library") # To pipe with %>%
library(dplyr) # To aggregate
library(forcats) # To reorder the data
library(ggplot2)

repositories_using_toggles <- read_csv("results/04_toggled_repositories_round_4.csv")

repos_per_language = repositories_using_toggles %>%
  select(library_language, repo_name) %>%
  group_by(library_language) %>%
  summarise(count = length(repo_name))

data <- repos_per_language %>%
  mutate(library_language = fct_reorder(library_language, count))

ymid <- mean(range(data$count))

data %>%
  mutate(library_language = fct_reorder(library_language, count)) %>%
  ggplot(aes(x=library_language, y=count, label=paste(library_language, signif(count/sum(count)*100, 2), "%"))) +
  geom_bar(stat="identity") +
  geom_text(mapping = aes(hjust = ifelse(count < ymid, -0.05, 1.1), color = ifelse(count < ymid, "white", "black")), size=5, fontface="bold") +
  scale_color_manual(values=c("white", "black")) +
  labs(title="Toggled Repositories by Language", y="") +
  coord_flip() +
  scale_y_sqrt() +
  theme_minimal() +
  theme(plot.title=element_text(hjust = 0.5),
        axis.text.y=element_blank(),
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        legend.text=element_text(size=11),
        legend.position="none") 
