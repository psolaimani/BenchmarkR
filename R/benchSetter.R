#' setTiming
#' @description updates .BenchEnv$BM data.frame by addition of given proccess duration
#' @param process name for the type of function (eg. READ, WRITE). 
#' @param start start time process
#' @param end end time process
#' @param compute whether to substract timedFunctions from total time.
#' Default is TRUE.
#' @return adds a record to .BenchEnv$BM data.frame
setTiming <- function(process, start, end, compute = TRUE) {
  benchmarks <- benchGetter(target = "benchmarks")
  systemId   <- benchGetter(target = "systemid")
  runId      <- benchGetter(target = "runid")
  File       <- benchGetter(target = "file")
  bench_v    <- benchGetter(target = "bench_version", file = File)
  runs       <- benchGetter(target = "runs")
  
  if (compute) {
    duration <- benchGetter(target = "computetime", runId = runId)
  } else {
    duration <- end - start
  }
  
  .BenchEnv$BM <- rbind(
    benchmarks, 
    data.frame(
      runId = runId,
      systemId = systemId,
      file = .BenchEnv$file,
      version = bench_v,
      process = process,
      start = start,
      end = end,
      duration = duration,
      runs = runs,
      stringsAsFactors = FALSE
    )
  )
}

#' setSystemID
#' @description Generats a unique ID for the system on which the benchmark
#' is runned ones on loading of package and stores system information with 
#' this ID.
#' @return unique id as character vector and system information are added 
#' as record to .BenchEnv$META data.frame
#' @importFrom parallel detectCores
#' @import digest
setSystemID <- function() {
  
  if (exists('systemId', envir = .BenchEnv) == FALSE ) {
    warning("systemId doesn't exist.\n")
    needSysId <- TRUE
  } else {
    if (nchar(.BenchEnv$systemId) != 32 | class(.BenchEnv$systemId) != "character") {
      warning("Your systemId has incorrect format.\n")
      needSysId <- TRUE
    } else {
      message(sprintf("systemId exists: %s", .BenchEnv$systemId))
      needSysId <- FALSE
    }
  }
  
  if (needSysId) {
    attributes <- c(
      R.Version()[c("arch", "os", "major", "minor", "language", "version.string")],
      Sys.info()[c("sysname", "release", "version")],
      nphyscores = parallel::detectCores(logical = FALSE), 
      nlogcores = parallel::detectCores(logical = TRUE)
    )
    
    all_attributes <- paste(attributes, sep= "", collapse = "")
    systemId <- digest::digest(all_attributes, serialize = FALSE) 
    
    message("Saving system information to .BenchEnv$META...")
    for (i in 1:length(names(attributes))){
      .BenchEnv$META[i, ] <- c(systemId, names(attributes)[i], attributes[[i]] )
    }
    
    assign("systemId", systemId, envir = .BenchEnv)
    message(sprintf("Generated and assigned system ID: %s", .BenchEnv$systemId))
    
    return(invisible(.BenchEnv$systemId))
    
  } else {
    return(invisible(.BenchEnv$systemId))
  }
}