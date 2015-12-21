# functions for cleaning data.frame created by benchmaRk

benchCleaner <- function(target){
  # Cleans target data.frame/files

  target <- tolower(target)

  if(target == "timings"){
    # removes all records in TIMINGS
    ExecEnvironment$TIMINGS <- NULL
  }

  if(target == "benchmarks"){
    # removes all records in BENCHMARKS
    ExecEnvironment$BENCHMARKS <- NULL
  }

  if(target == "meta"){
    # removes all records in META
    ExecEnvironment$META <- NULL
  }

  if(target == "warnings"){
    # removes all records in WARNINGS
    ExecEnvironment$WARNINGS <- NULL

  }

  if(target == "timedfunctionfile"){
    # removes timedFunctions.R file
    file.remove("R/timedFunctions.R", showWarnings = FALSE)
  }
}
