# functions for cleaning data.frame created by benchmarkR

benchCleaner <- function(target){
  # Cleans target data.frame/files

  target <- tolower(target)

  if(target == "profiles"){
    # removes all records in PROFILES
    ExecEnvironment$PROFILES <- NULL
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
}
