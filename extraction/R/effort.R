library(readr)

# Toggle effort
commits <- read_csv('analysis/merged/rq1-commits.csv')

print(summary(commits))

pdf(paste("importance_plot.pdf", sep=""), width=3, height=1.5)
par(mar=c(0, 2, 2, 0), mai=c(0.5, 0.1, 0.4, 0.1))

boxplot(commits$toggle_effort * 100, horizontal=TRUE)
print(boxplot.stats(commits$toggle_effort))
title("Effort invested in toggles (%)", cex.main=0.8)

dev.off()



# Coverage
# loc <- read_csv('analysis/merged/rq1-loc.csv')
# print(summary(loc))
# boxplot(loc$coverage)
# print(boxplot.stats(loc$coverage))
# title("Coverage ratio", cex.main=1)