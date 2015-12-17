cleanTimings <- function(){
  # removed all records in TIMINGS
  ExecEnvironment$TIMINGS <- NULL
}

cleanBenchmarks <- function(){
  # removes all records in BENCHMARKS
  ExecEnvironment$BENCHMARKS <- NULL
}

cleanMeta <- function(){
  # removes all records in META
  ExecEnvironment$META <- NULL
}

cleanWarnings <- function(){
  # removes all records in WARNINGS
  ExecEnvironment$WARNINGS <- NULL
}

setTiming <- function(process, start, end){
  # updates TIMINGS data.frame by addition of given proccess duration
  duration <- end - start
  ExecEnvironment$TIMINGS <- rbind(
    ExecEnvironment$TIMINGS,
    data.frame(runId = BenchmarkEnvironment$runId,
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
  Timings <- getTimeRun(runId)
  runTime <- sum(subset(Timings, process == "BENCHMARK")$duration) -
                   sum(subset(Timings, process != "BENCHMARK")$duration)
  return(runTime)
}

setBenchmark <- function(){
  # adds last benchmark to benchmark results
  runId <- BenchmarkEnvironment$runId
  file <- BenchmarkEnvironment$file
  time <- calcComputeTime(runId)
  ExecEnvironment$BENCHMARKS <- rbind(ExecEnvironment$BENCHMARKS,
                                      data.frame(
                                        runId = runId,          # unique runId
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
  cat(sprintf("\nNumber of direct calls detected: %i\n",direct_call_detected))
}
