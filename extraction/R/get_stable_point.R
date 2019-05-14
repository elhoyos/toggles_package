get_nonzero_survival_index <- function(survivalfit) {
  surv <- survivalfit$surv
  len <- length(surv)
  if (len > 1 && surv[len] == 0) {
    return(len-1)
  }

  return(len)
}

# Returns the last point at which an asymmptotic survival curve
# stabilizes after a change in the survival probability.
get_stable_point <- function(survivalfit, delta=0.05) {
  seek <- get_nonzero_survival_index(survivalfit)
  time <- survivalfit$time[1:seek]
  survival <- survivalfit$surv[1:seek]
  size <- length(time)
  point <- list(time=time[size], survival=survival[size])
  
  if (size < 2) {
    return(point)
  }
  
  stable_p <- point$survival
  for (i in (size - 1):1) {
    survival_p <- survival[i]
    if ((survival_p - stable_p) > delta) {
      break
    }
    point <- list(time=time[i], survival=survival_p)
  }
  
  return(point)
}
