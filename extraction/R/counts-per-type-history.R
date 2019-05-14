library(readr)
library("magrittr", lib.loc="/usr/local/lib/R/3.3/site-library") # To pipe with %>%
library(ggplot2)
library(dplyr)
library(reshape2)

rq2_counts_per_type_history <- read_csv("rq2-counts-per-type-history.csv")

data <- melt(rq2_counts_per_type_history, id.vars = "row")

totals <- data %>%
  group_by(variable) %>%
  summarize(total = sum(value))

totals_op <- data %>%
  group_by(row) %>%
  summarize(total = sum(value))

palette <- c("#28659C", "#800000", "#E69F00")

data %>%
  ggplot(aes(x=variable, y=value, fill=row, label=paste(round(value/sum(value)*100), "%"))) +
  geom_bar(stat="identity") +
  geom_text(size=10, fontface="bold", position=position_stack(vjust=0.5), color="white") +
  labs(x="Toggle Components", y="Number of Events") +
  scale_fill_manual(name="", values=palette, labels = paste(totals_op$row, "(", totals_op$total, ")")) +
  scale_y_log10() +
  coord_fixed(ratio = 0.8) +
  theme_minimal() +
  theme(axis.title.x=element_text(size=30),
        axis.text.x=element_text(vjust = 4, size=20),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        legend.text=element_text(size=20),
        legend.position="bottom")

