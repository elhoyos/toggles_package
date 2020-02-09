# Common utility functions

no_org <- function(repo_name) {
  return(sub(".*/", "", repo_name))
}