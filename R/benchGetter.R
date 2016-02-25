#' benchGetter
#' @description Retrieve different saved records or benchmark information
#' @param target which information to retrieve 
#'    \code{id}: generates a unique ID based on date/time and a random number. 
#'    \code{benchmarks}: returns table with all recorded benchmarks. 
#'    \code{profile}: returns 'returnCol' from PROFILES where 'indexCol' == 'selectValue'. 
#'    \code{profilerun}: returns PROFILES table subsetted with runId. 
#'    \code{warnings}: returns ExecEnvironment$WARNINGS data.frame containing all warnings recorded. 
#'    \code{systemid}: returns the unique systemId that is used to identify this system. 
#' @param indexCol profiling records will be filtered based on content of this column
#' @param returnCol content of this column will be returned after filtering
#' @param selectValue this value will be compared to indexCol to filter profiling records
#' @param selectedRunId which runId to use for filtering profiling records
#' @param file packages used in this file will be extracted and installed
#' @importFrom utils installed.packages
#' @export
benchGetter <- function(target, indexCol = NULL, returnCol = NULL, selectValue = NULL, selectedRunId = NULL, file = NULL, runId = NULL){

  target = tolower(target)

  if (target == "id"){
    # Generates a unique ID
    exactTime <- format(Sys.time(), "%y%m%d%H%M%S")
    randomNum <- sample(100000:999999, 1)
    id <- as.character(paste0(exactTime,randomNum))
    return(id)
  }

  if (target == "benchmarks"){
    return(.BenchEnv$BENCHMARKS)
  }

  if (target == "profile"){
    if(is.null(indexCol)  | is.null(returnCol) |  is.null(selectValue) ){
      warning("\nRowname, columnname, or condition for subsetting Profiling data.frame is not provided.\n")
      return(NULL)
    }
    return(.BenchEnv$BENCHMARKS[.BenchEnv$BENCHMARKS[indexCol] == selectValue, returnCol])
  }

  if(target == "profilerun"){
    if(is.null(selectedRunId)){
      warning("\nNo or empty selectedRunId provided for calculating the running time.\n")
      return(NULL)
    }
    
    select_run <- .BenchEnv$BENCHMARKS[,grep('runId',colnames(.BenchEnv$BENCHMARKS))] == selectedRunId
    run <- .BenchEnv$BENCHMARKS[select_run,]
    return(run)
  }
  
  if (target == "systemid"){
    return(.BenchEnv$systemId)
  }
  
  if (target == "runid"){
    return(.BenchEnv$runId)
  }
  
  if (target == "file"){
    return(.BenchEnv$file)
  }
  
  if (target == "runs"){
    return(.BenchEnv$runs)
  }
  
  if (target == "bench_version") {
    bench_version <- Sys.getenv("SHA1")[[1]]
    if(length(bench_version) == 0) {
      if (is.null(file)){
        warning("Can't get version: no file or SHA1 env variable provided.\n")
        return(NULL)
      }
      bench_version <- tools::md5sum(file)
    }
    return(bench_version)
  }
  
  if (target == "meta"){
    return(.BenchEnv$META)
  }
  
  if (target == "computetime") {
    if(is.null(runId)){
      warning("\nNo or empty runId provided for calculating the running time.\n")
      return(NULL)
    }
    # returns running time script minus running time reading/writing data for a given runId
    Profile <- benchGetter( target = "profilerun", selectedRunId = runId )
    incl <- Profile[, grep("process", colnames(Profile) ) ] == "BENCHMARK"
    excl <- Profile[, grep("process", colnames(Profile) ) ] != "BENCHMARK"
    time_include <- sum( as.numeric(Profile[ incl,]$duration ) )
    time_exclude <- sum( as.numeric( Profile [ excl,]$duration ) )
    runTime <- time_include - time_exclude
    return( runTime )
    
  }
}