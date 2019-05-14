library(survival)

options(
  warn=2 # Exit if a warning
)

source("./R/get_stable_point.R")

eq <- function(x, y) {
  if (!isTRUE(all.equal(x, y, tolerance=0.1))) {
    stop(paste("expected", unlist(x), "to equal", unlist(y), collapse=', '))
  }
}

data <- data.frame(time=  c(1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3),
                   status=c(1,1,1,1,1,1,1,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,1,1))

fit <- survfit(Surv(time, status) ~ 1, data=data)
summary(fit, censored=TRUE)

eq(get_stable_point(fit, delta=0.01), list(time=2, survival=0.56))