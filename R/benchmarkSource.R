# Generate and store systemId and system information
setSystemID()

benchmarkSource <- function(file,timed_functions=NULL) {
  # This script will benchmark the runningtime of the given input file
  # The time used by functions defined in timed.<...>.functions.R will
  # be subtracted from total running time.
  #
  # Profile of all runned benchmarks: getAllTimings()
  # Benchmarks of all runned benchmarks: getAllBenchmarks()
  # All benchmark specific warnings: getAllWarnings()
  #

  # remove timedFunctions.R file
  benchCleaner("TimedFunctionFile")

  # install all used packages not yet installed on the system
  benchGetter(file = file,type = "UsedPackages")

  # load all timed functions in BenchmarkEnvironment
  addProfiler(timed_functions)

  # get a unique ID to identify this benchmark
  runId <- benchGetter(type = "Id")

  # save file name and runId to BenchmarkEnvironment for use by
  # setter/getter/etc functions in that environment
  assign("file", file, envir = BenchmarkEnvironment)
  assign("runId", runId, envir = BenchmarkEnvironment)

  # Check content input file for use of direct calling of functions from packages
  # by package::function() annotation.
  checkSource(file,runId)

  # start timing benchmark
  B_start <- as.numeric(Sys.time())
  source(file, local = ExecEnvironment)
  B_end <- as.numeric(Sys.time())

  # add BENCHMARK timing to timings of the script (and its components)
  setTiming(p="BENCHMARK", s=B_start, e=B_end)

  # add BENCHMARK timing to all other benchmarks stored in ExecEnvironment$BENCHMARKS
  setBenchmark()

  # get all recorded benchmarks
  benchmark <- benchGetter(type = "allbenchmarks")

  # return the last benchmark result
  return(benchmark[,]$time[nrow(benchmark)])
}
