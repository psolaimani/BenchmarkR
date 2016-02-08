#' setTiming
#' @description updates PROFILES data.frame by addition of given proccess duration
#' @param process name for the type of function (eg. READ, WRITE). 
#' @param start start time process
#' @param end end time process
#' @return adds a record to ExEnv$PROFILES data.frame
#' @export
setTiming <- function( process, start, end ) {
  Profiles <- benchGetter( target = "profiles")
  systemId <- benchGetter( target = "systemid" )
  runId <- benchGetter( target = "runid")
  duration <- end - start
  
  .BenchEnv$PROFILES <- rbind(Profiles, data.frame(runId = .BenchEnv$runId,
                                                     systemId = systemId,
                                                     file = .BenchEnv$file,
                                                     process = process,
                                                     start = start,
                                                     end = end,
                                                     duration = duration)
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
  cat("\nWriting this benchmark results to .BenchEnv$BENCHMARKS...\n")
  cat("Get benchmark results using benchGetter('benchmarks')\n")
  runId <- .BenchEnv$runId
  systemId <- .BenchEnv$systemId
  file <- .BenchEnv$file
  time <- calcComputeTime( runId = runId )
  
  .BenchEnv$BENCHMARKS <- rbind( .BenchEnv$BENCHMARKS,
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
#' @param file name of the file being benchmarked (.BenchEnv$file)
#' @param runId runId of the current benchmark (.BenchEnv$runId)
#' @return number of direct calls detected (invisble), warning with number of direct calls is printed to console
#' @export
checkSource <- function(file = .BenchEnv$file, runId = .BenchEnv$runId ){
  cat("\nChecking for direct calls in code...\n")
  direct_calls_detected <- 0
  content <- readLines( file )
  lineOfDirectCalls <- grep( "(::|:::)", content )
  direct_calls_detected <- length( lineOfDirectCalls )
  for(call in lineOfDirectCalls ) {
    .BenchEnv$WARNINGS <- rbind( .BenchEnv$WARNINGS,
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
    
    all_attributes <- paste0(attributes, sep= "", collapse = "")
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
