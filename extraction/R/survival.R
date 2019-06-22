library(survival)
library(readr)
library(beanplot)
library(magrittr)
library(dplyr)

options(
  warn=2, # Exit if a warning
  stringsAsFactors=FALSE # Do not convert strings to factors when loading csv files
)

source("./R/get_stable_point.R")

no_org <- function(repo_name) {
  return(unlist(strsplit(repo_name, "/", fixed = TRUE))[2])
}

SECONDS = 86400 * 7 # Each week
stabilization_delta = 0.01

base_path <- "./analysis/raw/"
projects <- c('edx__edx-enterprise', 'acfrmarine__squidle', 'azavea__nyc-trees', 'ccnmtl__capsim', 'ccnmtl__dmt', 'ccnmtl__footprints', 'ccnmtl__forest', 'ccnmtl__match', 'ccnmtl__mediathread', 'ccnmtl__nepi', 'ccnmtl__phtc', 'ccnmtl__smart_sa', 'ccnmtl__wardenclyffe', 'CenterForOpenScience__osf.io', 'dionyziz__crypto-class', 'djangocon__2015.djangocon.us-archived', 'edx__course-discovery', 'edx__credentials', 'edx__ecommerce', 'edx__edx-analytics-dashboard', 'edx__edx-platform', 'erudit__eruditorg', 'gbozee__pyconng', 'hmgoalie35__ayrabo', 'kh-004-webuipython__Jiller', 'mangroveorg__datawinners', 'ministryofjustice__manchester_traffic_offences_pleas', 'mozilla__bedrock', 'mozilla__fjord', 'mozilla__kitsune', 'mozilla__zamboni', 'mozilla-services__push-dev-dashboard', 'mozilla-services__socorro', 'ORGAN-IZE__register', 'python__pythondotorg', 'thraxil__artsho', 'thraxil__spokehub', 'tndatacommons__tndata_backend', 'trailhawks__lawrencetrailhawks', 'unicef__rhizome')
# projects <- c('trailhawks__lawrencetrailhawks')
paths <- paste(base_path, projects, sep="")

filenames = dir(pattern="^rq3-survival.csv$", path = paths, full.names = TRUE, recursive = TRUE)
survival <- data.frame()
stable_points = data.frame(matrix(ncol = 3, nrow = 0))

# Colors
col = 1:4

for (i in 1:length(filenames)) {
  data <- read.csv(filenames[i])
  repo_name <- data$repo_name[1]
  print(repo_name)

  survival <- rbind(survival, data)

  kmsurvival <- survfit(Surv(ceiling(data$epoch_interval/SECONDS), data$removed) ~ 1)
  print(summary(kmsurvival, censored=TRUE))

  # project = sub("\\.", "_", sub("/", "__", repo_name))
  # pdf(paste("survival_", project, ".pdf", sep=""), width=5, height=4)
  # # par needs to be here so the pdf gets the right margins
  # par(mar=c(4, 3.5, 2, 0))
  # plot(kmsurvival, col=col)
  # title(main=no_org(repo_name), ylab="Survival Function", xlab="Weeks", mgp=c(2.5, 0, 0), cex.lab=1.2, cex.main=2)
  # box(lwd=1.95)
  # legend("topright", inset=c(0.01, 0), legend=c("Estimate","Lower 95%","Upper 95%"), col=col, lty=1, bty="n", cex=0.8, y.intersp=1.2)
  # dev.off()

  stable_point <- c(list(repo_name=repo_name), get_stable_point(kmsurvival, stabilization_delta))
  stable_points = rbind(stable_points, data.frame(stable_point))
}

summary(stable_points)

options(scipen=999) # Disable scientific notation

pdf("figure_removal_stabilization.pdf",  width=3, height=2)
par(mgp=c(2.3, 1, 0), mar=c(3.5, 0.1, 0.1, 0.1))
boxplot(stable_points$time,
        horizontal = TRUE,
        xlab="Weeks to stop removing components",
        col = "grey")
dev.off()

pdf("figure_survival_stabilization.pdf",  width=3, height=2)
par(mgp=c(2.3, 1, 0), mar=c(3.5, 0.1, 0.1, 0.1))
boxplot(stable_points$survival * 100,
        horizontal = TRUE,
        xlab="% remaining components",
        col = "grey")
dev.off()

ops_per_type <- stable_points %>%
  left_join(read_csv('analysis/merged/rqX-operations-per-type.csv')) %>%
  left_join(read_csv('analysis/waffle_repositories.csv')) %>%
  select(repo_name, num_toggles_aprox, number_of_commits, time, survival)

pdf("figure_survival_vs_toggles_vs_commits.pdf", width=5, height=4)
par(mfrow=c(1, 2))
plot(ops_per_type$num_toggles_aprox,
     ops_per_type$survival * 100,
     xlab = "Number of toggles",
     ylab = "")
plot(ops_per_type$number_of_commits,
     ops_per_type$survival * 100,
     xlab = "Number of commits",
     ylab = "")
dev.off()

