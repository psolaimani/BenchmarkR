#' setTiming
#' @description updates PROFILES data.frame by addition of given proccess duration
#'
#' @param process name for the type of function (eg. READ, WRITE). 
#' @param start start time process
#' @param end end time process
#'
#' @return adds a record to ExecEnvironment$PROFILES data.frame
#' @export
setTiming <- function(process, start, end){
  systemId <- benchGetter("systemid")
  duration <- end - start
  ExecEnvironment$PROFILES <- rbind(
    ExecEnvironment$PROFILES,
    data.frame(runId = BenchmarkEnvironment$runId,
               systemId = systemId,
               file = BenchmarkEnvironment$file,
               process,
               start,
               end,
               duration,
               stringsAsFactors = F)
  )
}


#' calcComputeTime
#' @description calculates process running time.
#' @param runId runId of the benchmark/profiling for which running time is to be calculated.
#' @return Running time of the benchmark minus time used by functions provided for profiling.
#' @export
calcComputeTime <- function(runId){
  # returns running time script minus running time reading/writing data for a given runId
  cat("\nComputing benchmark: subtracting I/O from total running time...\n")
  Profile <- benchGetter("profilerun",selectedRunId=runId)
  incl <- Profile[,grep("process",colnames(Profile))] == "BENCHMARK"
  excl <- Profile[,grep("process",colnames(Profile))] != "BENCHMARK"
  runTime <- sum(Profile[incl,]$duration) - sum(Profile[excl,]$duration)
  return(runTime)
}

#' setBenchmark
#' @description adds last benchmark to benchmark results.
#' @return Adds the running time of the whole script as a record to ExecEnvironment$BENCHMARKS data.frame
#' @export
setBenchmark <- function(){
  # adds last benchmark to benchmark results
  cat("\nWriting this benchmark results to ExecEnvironment$BENCHMARKS...\n")
  cat("You can get all the benchmark results using benchGetter('AllBenchmarks\n')")
  runId <- BenchmarkEnvironment$runId
  systemId <- benchGetter("systemid")
  file <- BenchmarkEnvironment$file
  time <- calcComputeTime(runId)
  ExecEnvironment$BENCHMARKS <- rbind(ExecEnvironment$BENCHMARKS,
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
#' @param file name of the file being benchmarked (BenchmarkEnvironment$file)
#' @param runId runId of the current benchmark (BenchmarkEnvironment$runId)
#' @return number of direct calls detected (invisble), warning with number of direct calls is printed to console
#' @export
checkSource <- function(file=BenchmarkEnvironment$file,runId=BenchmarkEnvironment$runId){
  cat("\nChecking for direct calls in code...\n")
  direct_calls_detected <- 0
  content <- readLines(file)
  lineOfDirectCalls <- grep("(::|:::)", content)
  direct_calls_detected <- length(lineOfDirectCalls)
  for(call in lineOfDirectCalls){
    ExecEnvironment$WARNINGS <- rbind(ExecEnvironment$WARNINGS,
                                      data.frame(
                                        runId = runId,          # unique runId
                                        file = file,    # full script name being benchmarked
                                        lineOfDirectCall = call      # detected direct function calls
                                      )
    )
  }
  cat(sprintf("\nNumber of direct calls detected: %i\n\n",direct_calls_detected))
  return(invisible(direct_call_detected))
}

#' setSystemID
#' @description Generats a unique ID for the system on which the benchmark  is runned ones
#' on loading of package and stores system information with this ID.
#' @return unique id as character vector and system information are added as record to ExecEnvironment$META data.frame
#' @importFrom parallel detectCores
#' @export
setSystemID <- function(){
  # 
  #
  cat("\nSaving system information to ExecEnvironment$META...\n")
  systemId <- benchGetter("id")
  attributes <- c(R.Version()[c("arch", "os", "major", "minor", "language", "version.string")],
                  Sys.info()[c("sysname", "release", "version")],
                  nphyscores=parallel::detectCores(logical = FALSE), nlogcores=parallel::detectCores(logical = TRUE))

  for (i in 1:length(names(attributes))){
    ExecEnvironment$META[i,] <- c(systemId, names(attributes)[i], attributes[[i]])
  }

}
