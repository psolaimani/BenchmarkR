# All setter functions used in benchmarkR package

setTiming <- function(process, start, end){
  # updates PROFILES data.frame by addition of given proccess duration
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

calcComputeTime <- function(runId){
  # returns running time script minus running time reading/writing data for a given runId
  cat("\nComputing benchmark: subtracting I/O from total running time...\n")
  Profile <- benchGetter("profilerun",selectedRunId=runId)
  incl <- Profile[,grep("process",colnames(Profile))] == "BENCHMARK"
  excl <- Profile[,grep("process",colnames(Profile))] != "BENCHMARK"
  runTime <- sum(Profile[incl,]$duration) - sum(Profile[excl,]$duration)
  return(runTime)
}

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

checkSource <- function(file=BenchmarkEnvironment$file,runId=BenchmarkEnvironment$runId){
  # This benchmark/profiling package can only distinguish read/write
  # commands that are used from this package. If in the input source
  # read/write operations are directly called using package::read.function()
  # then they wont be timed and substracted from the total run time. This
  # function, therefor, checks if functions within packages are directly called
  # using ::/::: notation. If this is the case, this function will print
  # warnings for each direct call.
  cat("\nChecking for direct calls in code...\n")
  direct_call_detected <- 0
  content <- readLines(file)
  lineOfDirectCalls <- grep("(::|:::)", content)
  direct_call_detected <- length(lineOfDirectCalls)
  for(call in lineOfDirectCalls){
    ExecEnvironment$WARNINGS <- rbind(ExecEnvironment$WARNINGS,
                                      data.frame(
                                        runId = runId,          # unique runId
                                        file = file,    # full script name being benchmarked
                                        lineOfDirectCall = call      # detected direct function calls
                                      )
    )
  }
  cat(sprintf("\nNumber of direct calls detected: %i\n\n",direct_call_detected))
}

setSystemID <- function(){
  # Generats a unique ID for the system on which the benchmark  is runned ones
  # on loading of package and stores system information with this ID.
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
