#' benchGetter
#' @description Retrieves information stored in package environment, such as
#' benchmark or profiling records, systemId, runId, meta information.
#' @param target which information to retrieve 
#'    \code{target}: 
#'    \code{benchmarks}: returns table with all recorded benchmarks. 
#'    \code{profile}: returns 'returnCol' from PROFILES where 'indexCol' == 'selectValue'. 
#'    \code{profilerun}: returns PROFILES table subsetted with runId. 
#'    \code{warnings}: returns ExecEnvironment$WARNINGS data.frame containing all warnings recorded. 
#'    \code{systemid}: returns the unique systemId that is used to identify this system. 
#' @param indexCol profiling records will be filtered based on content of this column
#' @param retCol content of this column will be returned after filtering
#' @param fltVal this value will be compared to indexCol to filter profiling records
#' @param fltRunId which runId to use for filtering profiling records
#' @return depending on target choice, either a vector or data frame
benchGetter <- function(target=c("id","benchmarks","profile","profilerun",
                                  "systemid","runid","file","runs", "run_ok", "timed_fun",
                                  "bench_version","meta","computetime"), 
                         idxCol = NULL, retCol = NULL, 
                         fltVal = NULL, fltRunId = NULL, 
                         file = NULL, runId = NULL) {
  
  target <- match.arg(target)
  
  result <- switch(
    target,
    "id" = {
      # Generates a unique ID
      exactTime <- format(Sys.time(), "%y%m%d%H%M%S")
      randomNum <- sample(100000:999999, 1)
      id <- as.character(paste0(exactTime,randomNum))
      id
    },
    
    "benchmarks" = {
      get("BM", envir = .BenchEnv, mode = "list", inherits = FALSE) 
    },
    
    "profile" = {
      if(is.null(idxCol)  | is.null(retCol) |  is.null(fltVal) ) {
        warning("Rowname, columnname, or condition for 
                subsetting Profiling data frame is not provided.")
        res <- NULL
      } else {
        res <- get("BM", envir = .BenchEnv, mode = "list", inherits = FALSE)
        res <- res[res[idxCol] == fltVal, retCol]
      }
      res
    },
    
    "profilerun" = {
      if(is.null(fltRunId)) {
        warning("No or empty selectedRunId provided for calculating the running time.")
        res <- NULL
      } else {
        flt_run <- .BenchEnv$BM[,grep('runId',colnames(.BenchEnv$BM))] == fltRunId
        run <- .BenchEnv$BM[flt_run,]
        res <- run
      }
      res
    },
    
    "systemid" = {
      get( "systemId", envir = .BenchEnv, mode = "character", inherits = FALSE )
    },
    
    "runid" = {
      get( "runId", envir = .BenchEnv, mode = "character", inherits = FALSE )
    },
    
    "timed_fun" = {
      e <- try(
        get("timed_fun", envir = .BenchEnv, mode = "list", inherits = FALSE )
        , TRUE)
      if(inherits(e, "try-error")) warning("timed_fun not provided.")
    },
    
    "file" = {
      get( "file", envir = .BenchEnv, mode = "character", inherits = FALSE )
    },
    
    "runs" = {
      get( "runs", envir = .BenchEnv, mode = "numeric", inherits = FALSE )
    },
    
    "run_ok" = {
      get( "run_ok", envir = .BenchEnv, mode = "character", inherits = FALSE )
    },
    
    "bench_version" = {
      bench_version <- Sys.getenv( "SHA1" )[[1]]
      if (bench_version == "") {
        if (is.null(file)){
          warning("Can't get version: no file or SHA1 env variable provided.\n")
          bench_version <- NULL
        } else {
          bench_version <- tools::md5sum(file)
        }
      }
      bench_version
    },
    
    "meta" = {
      get("META", envir = .BenchEnv, mode = "list", inherits = FALSE)
    },
    
    "computetime" = {
      if(is.null(runId)) runId <- benchGetter(target = "runid")
      warning("\nNo or empty runId provided for calculating the running time.\n")
      # returns running time script minus running time reading/writing data for a given runId
      Profile <- benchGetter(target = "profilerun", fltRunId = runId)
      incl <- Profile[, grep("process", colnames(Profile) ) ] == "BENCHMARK"
      excl <- Profile[, grep("process", colnames(Profile) ) ] != "BENCHMARK"
      time_include <- sum( as.numeric(Profile[ incl,]$duration ) )
      time_exclude <- sum( as.numeric( Profile [ excl,]$duration ) )
      runTime <- time_include - time_exclude
      runTime
    }
  )
  
  result
}