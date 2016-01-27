#' setTiming
#' @description updates PROFILES data.frame by addition of given proccess duration
#' @param process name for the type of function (eg. READ, WRITE). 
#' @param start start time process
#' @param end end time process
#' @return adds a record to ExEnv$PROFILES data.frame
#' @export
setTiming <- function( process, start, end ) {
  systemId <- benchGetter( target = "systemid" )
  duration <- end - start
  endDF <- nrow( ExEnv$PROFILES ) + 1
  ExEnv$PROFILES[ endDF, ] <- c(ExEnv$runId,
                                          systemId,
                                          ExEnv$file,
                                          process,
                                          start,
                                          end,
                                          duration
  )
}


#' calcComputeTime
#' @description calculates process running time.
#' @param runId runId of the benchmark/profiling for which running time is to be calculated.
#' @return Running time of the benchmark minus time used by functions provided for profiling.
#' @export
calcComputeTime <- function( runId ){
  # returns running time script minus running time reading/writing data for a given runId
  Profile <- benchGetter( target = "profilerun", selectedRunId = runId )
  incl <- Profile[, grep("process", colnames(Profile) ) ] == "BENCHMARK"
  excl <- Profile[, grep("process", colnames(Profile) ) ] != "BENCHMARK"
  time_include <- sum( as.numeric(Profile[ incl,]$duration ) )
  time_exclude <- sum( as.numeric( Profile [ excl,]$duration ) )
  runTime <- time_include - time_exclude
  return( runTime )
}

#' setBenchmark
#' @description adds last benchmark to benchmark results.
#' @return Adds the running time of the whole script as a record to ExecEnvironment$BENCHMARKS data.frame
#' @export
setBenchmark <- function(){
  # adds last benchmark to benchmark results
  cat("\nWriting this benchmark results to ExEnv$BENCHMARKS...\n")
  cat("Get benchmark results using benchGetter('benchmarks')\n")
  runId <- ExEnv$runId
  systemId <- ExEnv$systemId
  file <- ExEnv$file
  time <- calcComputeTime( runId = runId )
  ExEnv$BENCHMARKS <- rbind( ExEnv$BENCHMARKS,
                                      data.frame(
                                        runId = runId,          # unique runId
                                        systemId = systemId,
                                        file = file,    # full script name being benchmarked
                                        time = time      # duration process
                                      )
  )
}

#' checkSource
#' @description benchmarkR only read/write commands that are provided to benchmarkSource() are timed. 
#' Direct calls used by input script (package::function) are not timed and won't be substracted from the total run time. 
#' This function, therefore, checks if inside input script direct function calls are made using ::/::: notation. 
#' If this is the case, this function will print warnings for each direct call.
#' @param file name of the file being benchmarked (ExEnv$file)
#' @param runId runId of the current benchmark (ExEnv$runId)
#' @return number of direct calls detected (invisble), warning with number of direct calls is printed to console
#' @export
checkSource <- function(file = ExEnv$file, runId = ExEnv$runId ){
  cat("\nChecking for direct calls in code...\n")
  direct_calls_detected <- 0
  content <- readLines( file )
  lineOfDirectCalls <- grep( "(::|:::)", content )
  direct_calls_detected <- length( lineOfDirectCalls )
  for(call in lineOfDirectCalls ) {
    ExEnv$WARNINGS <- rbind( ExEnv$WARNINGS,
                                      data.frame(
                                        runId = runId,          # unique runId
                                        file = file,    # full script name being benchmarked
                                        lineOfDirectCall = call      # detected direct function calls
                                      )
    )
  }
  cat( sprintf("Number of direct calls detected: %i\n", direct_calls_detected) )
  cat( sprintf("\tLine[%i]: %s\n", lineOfDirectCalls, content[ lineOfDirectCalls ]) )
  return( invisible( direct_calls_detected ) )
}

#' setSystemID
#' @description Generats a unique ID for the system on which the benchmark  is runned ones
#' on loading of package and stores system information with this ID.
#' @return unique id as character vector and system information are added as record to ExecEnvironment$META data.frame
#' @export
setSystemID <- function(){
  
  systemId <- as.character( benchGetter( target = "id" ) )
  
  if ( try( exists( 'systemId' , envir = ExEnv) ) == FALSE ) {
    cat( sprintf("systemId doesn't exist. New systemId: %s\n", systemId) )
    needSysId <- TRUE
  } else {
    if ( nchar( ExEnv$systemId ) != 18 | class( ExEnv$systemId ) != "character") {
      cat( sprintf("Your systemId has incorrect format.\n New systemId: %s\n", systemId) )
      needSysId <- TRUE
    } else {
      cat( sprintf("systemId exists: %s\n", ExEnv$systemId) )
      needSysId <- FALSE
    }
  }
  
  if (needSysId == TRUE) {
    assign( "systemId", systemId, envir = ExEnv )
    cat( sprintf("Generated and assigned system ID: %s\n", ExEnv$systemId) )
    
    attributes <- c(
      R.Version()[ c( "arch", "os", "major", "minor", "language", "version.string" ) ],
      Sys.info()[ c( "sysname", "release", "version" ) ]
    )
    
    cat("Saving system information to ExEnv$META...\n")
    for (i in 1:length( names( attributes ) ) ){
      ExEnv$META[i,] <- c( ExEnv$systemId, names(attributes)[i], attributes[[i]] )
    }
    
    return( invisible( ExEnv$systemId ) )
    
  } else {
    return( invisible( ExEnv$systemId ) )
  }
  
}
