#' setTiming
#' @description updates PROFILES data.frame by addition of given proccess duration
#' @param process name for the type of function (eg. READ, WRITE). 
#' @param start start time process
#' @param end end time process
#' @return adds a record to ExEnv$PROFILES data.frame
#' @export
setTiming <- function( process, start, end, compute = TRUE ) {
  Profiles <- benchGetter( target = "benchmarks")
  systemId <- benchGetter( target = "systemid" )
  runId <- benchGetter( target = "runid")
  File <- benchGetter( target = "file")
  bench_version <- benchGetter( target = "bench_version", file = File)
  runs <- benchGetter( target = "runs")
  
  if(compute == TRUE){
    duration <- benchGetter(target = "computetime", runId = runId)
  } else {
    duration <- end - start
  }
  
  .BenchEnv$BENCHMARKS <- rbind(Profiles, data.frame(runId = runId,
                                                   systemId = systemId,
                                                   file = .BenchEnv$file,
                                                   version = bench_version,
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
#' @description Generats a unique ID for the system on which the benchmark  is runned ones
#' on loading of package and stores system information with this ID.
#' @return unique id as character vector and system information are added as record to ExecEnvironment$META data.frame
#' @importFrom parallel detectCores
#' @import digest
#' @export
setSystemID <- function(){
  
  if ( try( exists( 'systemId' , envir = .BenchEnv) ) == FALSE ) {
    warning("systemId doesn't exist.\n")
    needSysId <- TRUE
  } else {
    if ( nchar( .BenchEnv$systemId ) != 32 | class( .BenchEnv$systemId ) != "character") {
      warning("Your systemId has incorrect format.\n")
      needSysId <- TRUE
    } else {
      cat( sprintf("systemId exists: %s\n", .BenchEnv$systemId) )
      needSysId <- FALSE
    }
  }
  
  if (needSysId == TRUE) {
    attributes <- c(
      R.Version()[ c( "arch", "os", "major", "minor", "language", "version.string" ) ],
      Sys.info()[ c( "sysname", "release", "version" ) ],
      nphyscores=parallel::detectCores(logical = FALSE), nlogcores=parallel::detectCores(logical = TRUE)
    )
    
    all_attributes <- paste(attributes, sep= "", collapse = "")
    systemId <- digest::digest(all_attributes, serialize=FALSE)
    
    cat("Saving system information to .BenchEnv$META...\n")
    for (i in 1:length( names( attributes ) ) ){
      .BenchEnv$META[i,] <- c( systemId, names(attributes)[i], attributes[[i]] )
    }
    
    assign( "systemId", systemId, envir = .BenchEnv )
    cat( sprintf("Generated and assigned system ID: %s\n", .BenchEnv$systemId) )
    
    return( invisible( .BenchEnv$systemId ) )
    
  } else {
    return( invisible( .BenchEnv$systemId ) )
  }
  
}
