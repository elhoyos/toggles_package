library(readr)
library(magrittr) # To pipe with %>%
library(ggplot2)
library(dplyr)

data <- read_csv("counts-history.csv")

palette <- c("#28659C", "#800000", "#E69F00")

data %>%
  ggplot(aes(x=variable, y=value, fill=variable, label=value)) +
  geom_bar(stat="identity") +
  geom_text(size=15, fontface="bold", position=position_stack(vjust=0.5), color="white") +
  labs(x="Components Distribution", y="Number of Events") +
  scale_fill_manual(name="", values=palette) +
  scale_y_log10() +
  coord_fixed(ratio = 0.25) +
  theme_minimal() +
  theme(axis.title.x=element_text(size=30),
        axis.text.x=element_text(vjust = 4, size=20),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        legend.position="none")

