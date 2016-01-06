#' benchCleaner
#'
#' functions for cleaning data.frame created by benchmarkR
#' 
#' @param target define what to clean
#' \code{profiles} clears all profiling records (ExecEnvironment$PROFILES)
#' \code{benchmarks} clears all benchmark records (ExecEnvironment$BENCHMARKS)
#' \code{meta} clears all records about the system (ExecEnvironment$META)
#' \code{warnings} clears all recorded warnings (ExecEnvironment$WARNINGS)
#' 
#' @export
benchCleaner <- function(target){
  # Cleans target data.frame/files

  target <- tolower(target)

  if(target == "profiles"){
    ExecEnvironment$PROFILES <- NULL
    ExecEnvironment$PROFILES <- data.frame(
      runId = character(0),
      systemId = character(0),
      file = character(0),
      process = character(0),
      start = numeric(0),
      end = numeric(0),
      duration = numeric(0)
      , stringsAsFactors = F
    )
  }

  if(target == "benchmarks"){
    ExecEnvironment$BENCHMARKS <- NULL
    ExecEnvironment$BENCHMARKS <- data.frame(
      runId = character(0),
      systemId = character(0),
      file = character(0),
      time = numeric(0)
      , stringsAsFactors = F
    )
  }

  if(target == "meta"){
    ExecEnvironment$META <- NULL
    ExecEnvironment$META <- data.frame(
      systemId = character(0),
      systemAttribute = character(0),
      attributeValue = character(0)
      , stringsAsFactors = F
    )
  }

  if(target == "warnings"){
    ExecEnvironment$WARNINGS <- NULL
    ExecEnvironment$WARNINGS <- data.frame(
      runId = character(0),
      file = character(0),
      lineOfDirectCall = integer(0)
      , stringsAsFactors = F
    )
  }
}
