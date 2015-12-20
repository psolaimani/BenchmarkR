# Profile Factory
# This allows easy addition of functions to be timed by command
# addProfiler(timed_fun, package, category)
#   timed_fun:  function to be timed
#   package:    name of the package that contains this timer
#   category:   name for process category that should be used in profile eg READ, WRITE, ...

ProfileFactory <- function(timed_fun, package, category){
  # This function writes the necessary lines for timing a function to
  # a R file that will be sources to override the functions locally.
  # The added lines will be of format:
  #
  #   BenchmarkEnvironment$read.table <- function(...){
  #     start <- as.numeric(Sys.time())
  #     utils::read.table(...)
  #     end <- as.numeric(Sys.time())
  #     duration <- end - start
  #     setTiming(p="READ", s=start, e=end)
  #   }
  #

  if(!exists(file("R/timedFunctions.R"))){
    file.create("R/timedFunctions.R")
  }

  con <- file("R/timedFunctions.R", "at")

  writeLines(
    c(
      paste0("BenchmarkEnvironment$",timed_fun," <- function(...){",
      "  start <- as.numeric(Sys.time())",
      paste0(package,"::",timed_fun,"(...)",
      "  duration <- end - start",
      "  setTiming(p="READ", s=start, e=end)",
      "}",
      " "
    ),
    sep = "\n"
    con = con
  )

  cat(sprintf("\nwrote timed function: %s\n"),paste0(package,"::",timed_fun,"(...)")

}

