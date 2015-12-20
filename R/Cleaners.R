# functions for cleaning data.frame created by benchmaRk

cleanTimings <- function(){
  # removes all records in TIMINGS
  ExecEnvironment$TIMINGS <- NULL
}

cleanBenchmarks <- function(){
  # removes all records in BENCHMARKS
  ExecEnvironment$BENCHMARKS <- NULL
}

cleanMeta <- function(){
  # removes all records in META
  ExecEnvironment$META <- NULL
}

cleanWarnings <- function(){
  # removes all records in WARNINGS
  ExecEnvironment$WARNINGS <- NULL
}

cleanTimedFunctionFile <- function(){
  # removes timedFunctions.R file
  file.remove("R/timedFunctions.R")
}
