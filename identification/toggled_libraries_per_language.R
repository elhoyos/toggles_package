library(readr)
library("magrittr", lib.loc="/usr/local/lib/R/3.3/site-library") # To pipe with %>%
library(dplyr) # To aggregate
library(forcats) # To reorder the data
library(ggplot2)

libraries <- read_csv("trace-sets.csv")

repos_per_language = libraries %>%
  filter(Repositories != "") %>%
  select(Languages, Library) %>%
  group_by(Languages) %>%
  summarise(count = length(Library))

data <- repos_per_language %>%
  mutate(Languages = fct_reorder(Languages, count))

ymid <- mean(range(data$count))

data %>%
  mutate(Languages = fct_reorder(Languages, count)) %>%
  ggplot(aes(x=Languages, y=count, label=paste(Languages, count, sep = ": "))) +
  geom_bar(stat="identity") +
  geom_text(mapping = aes(hjust = ifelse(count < ymid, -0.05, 1.1), color = ifelse(count < ymid, "white", "black")), size=5, fontface="bold") +
  scale_color_manual(values=c("white", "black")) +
  labs(title="Libraries per Language", y="") +
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
