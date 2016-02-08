#' benchGetter
#' @description Retrieve different saved records or benchmark information
#' @param target which information to retrieve 
#'    \code{id}: generates a unique ID based on date/time and a random number. 
#'    \code{profiles}: returns all records of PROFILES table. 
#'    \code{benchmarks}: returns table with all recorded benchmarks. 
#'    \code{profile}: returns 'returnCol' from PROFILES where 'indexCol' == 'selectValue'. 
#'    \code{profilerun}: returns PROFILES table subsetted with \code{runId}. 
#'    \code{warnings}: returns ExecEnvironment$WARNINGS data.frame containing all warnings recorded. 
#'    \code{systemid}: returns the unique systemId that is used to identify this system. 
#' @param indexCol profiling records will be filtered based on content of this column
#' @param returnCol content of this column will be returned after filtering
#' @param selectValue this value will be compared to \code{indexCol} to filter profiling records
#' @param selectedRunId which \code{runId} to use for filtering profiling records
#' @param file packages used in this file will be extracted and installed
#' @importFrom utils installed.packages
#' @export
benchGetter <- function(target, indexCol = NULL, returnCol = NULL, selectValue = NULL, selectedRunId = NULL, file = NULL){

  target = tolower(target)

  if (target == "id"){
    # Generates a unique ID
    exactTime <- format(Sys.time(), "%y%m%d%H%M%S")
    randomNum <- sample(100000:999999, 1)
    id <- as.character(paste0(exactTime,randomNum))
    return(id)
  }

  if (target == "profiles"){
    return(.BenchEnv$PROFILES)
  }

  if (target == "benchmarks"){
    return(.BenchEnv$BENCHMARKS)
  }

  if (target == "profile"){
    if(is.null(indexCol)  | is.null(returnCol) |  is.null(selectValue) ){
      warning("\nRowname, columnname, or condition for subsetting Profiling data.frame is not provided.\n")
      return(NULL)
    }
    return(.BenchEnv$PROFILES[.BenchEnv$PROFILES[indexCol] == selectValue, returnCol])
  }

  if(target == "profilerun"){
    if(is.null(selectedRunId)){
      warning("\nNo or empty selectedRunId provided for calculating the running time.\n")
      return(NULL)
    }
    
    select_run <- .BenchEnv$PROFILES[,grep('runId',colnames(.BenchEnv$PROFILES))] == selectedRunId
    run <- .BenchEnv$PROFILES[select_run,]
    return(run)
  }

  if (target == "warnings"){
    return(.BenchEnv$WARNINGS)
  }
  
  if (target == "systemid"){
    return(.BenchEnv$systemId)
  }
  
  if (target == "runid"){
    return(.BenchEnv$runId)
  }
  
  if (target == "meta"){
    return(.BenchEnv$META)
  }
}