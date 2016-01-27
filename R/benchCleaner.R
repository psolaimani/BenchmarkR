#' benchCleaner
#' @description functions for cleaning data.frame created by benchmarkR
#' @param target define what to clean. 
#' \code{profiles}: clears all profiling records. 
#' \code{benchmarks}: clears all benchmark records. 
#' \code{meta}: clears all records about the system. 
#' \code{warnings}: clears all recorded warnings. 
#' @export
benchCleaner <- function(target){
  # Cleans target data.frame/files
  target <- tolower(target)

  if(target == "profiles"){
    ExEnv$PROFILES <- NULL
    ExEnv$PROFILES <- data.frame(
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
    ExEnv$BENCHMARKS <- NULL
    ExEnv$BENCHMARKS <- data.frame(
      runId = character(0),
      systemId = character(0),
      file = character(0),
      time = numeric(0)
      , stringsAsFactors = F
    )
  }

  if(target == "meta"){
    ExEnv$META <- NULL
    ExEnv$META <- data.frame(
      systemId = character(0),
      systemAttribute = character(0),
      attributeValue = character(0)
      , stringsAsFactors = F
    )
  }

  if(target == "warnings"){
    ExEnv$WARNINGS <- NULL
    ExEnv$WARNINGS <- data.frame(
      runId = character(0),
      file = character(0),
      lineOfDirectCall = integer(0)
      , stringsAsFactors = F
    )
  }
}
