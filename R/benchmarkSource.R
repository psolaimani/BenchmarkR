#' benchmarkSource
#' @title Simple Benchmark/Profiling Tool For R Scripts
#' @author Parham Solaimani
#' @author Maarten-Jan Kallen
#' @author Alexander Bertram
#' @keywords benchmark benchmarking profiling timing r script file
#' @description This script will benchmark the running time of the given input file. Time used by functions defined in timed_fun data.frame will be subtracted from total running time.
#' @usage benchmarkSource(file,timed_fun)
#' @param file R script to benchmark
#' @param timed_fun a data.frame whith 4 columns. Column 1: function; column 2: package; column 3: process category eg. READ/WRITE but never BENCHMARK; column 4: function type, currently only 'IO'.
#' @return returns a dubble with running time of last benchmark and prints all session benchmark records to console
#' @export 
benchmarkSource <- function(file,timed_fun = NULL) {
  
  # check if provided file exists
  if(!file.exists(file)){
    cat(sprintf("\nProvided file does not exist.\nFile: %s\n", file))
    return(NULL)
  }
  
  # generate and set system id if its not generated 
  setSystemID()

  # install all used packages not yet installed on the system
  benchGetter(file = file, target = "UsedPackages")

  # load all timed functions in BenchmarkEnvironment
  addProfiler(timed_fun)

  # get a unique ID to identify this benchmark
  runId <- as.character( benchGetter(target = "Id") )

  # save file name and runId to BenchmarkEnvironment for use by
  # setter/getter/etc functions in that environment
  assign("file", file, envir = BenchmarkEnvironment)
  assign("runId", runId, envir = BenchmarkEnvironment)

  # Check content input file for use of direct calling of functions from packages
  # by package::function() annotation.
  checkSource(file = file, runId = runId)

  # start timing benchmark
  B_start <- as.numeric(Sys.time())
  source(file, local = ExecEnvironment)
  B_end <- as.numeric(Sys.time())

  # add BENCHMARK timing to timings of the script (and its components)
  setTiming(process ="BENCHMARK", start = B_start, end = B_end)
  # add BENCHMARK timing to all other benchmarks stored in ExecEnvironment$BENCHMARKS
  setBenchmark()
  # get all recorded benchmarks
  benchmark <- benchGetter(target = "benchmarks")

  # return the last benchmark result
  return(benchmark[,]$time[nrow(benchmark)])
}