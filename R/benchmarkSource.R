#' benchmarkSource
#' @title Simple Benchmark/Profiling Tool For R Scripts
#' @author Parham Solaimani
#' @author Maarten-Jan Kallen
#' @author Alexander Bertram
#' @keywords benchmark benchmarking profiling timing r script file
#' @description This script will benchmark the running time of the given input file. Time used by functions defined in timed_fun data.frame will be subtracted from total running time.
#' @usage benchmarkSource(file,timed_fun)
#' @param file R script to benchmark
#' @param bench_name Name (character) of the benchmark that is being runned
#' @param timed_fun a data.frame whith 4 columns. Column 1: function; column 2: package; column 3: process category eg. READ/WRITE but never BENCHMARK; column 4: function type, currently only 'IO'.
#' @return returns a dubble with running time of last benchmark and prints all session benchmark records to console
#' @import packrat
#' @export 
benchmarkSource <- function(file, bench_name, timed_fun = NULL) {
  
  # check if provided file exists
  if(!file.exists(file)){
    warning(sprintf("\nDoesn't exists: %s\n", file))
    return(NULL)
  }
  
  # generate and set system id if its not generated 
  setSystemID()

  # load all timed functions in BenchmarkEnvironment
  addProfiler(timed_fun)

  # get a unique ID to identify this benchmark
  runId <- as.character( benchGetter(target = "Id") )

  # save file name and runId to .BenchEnv for use by
  # setter/getter/etc functions in that environment
  assign( "file", file, envir = .BenchEnv )
  assign( "runId", runId, envir = .BenchEnv )
  
  cat(sprintf("runId:  \t%s\nsystemId:\t%s\n",benchGetter(target = "runid"),benchGetter(target = "systemid")))
  
  # Check content input file for use of direct calling of functions from packages
  # by package::function() annotation.
  checkSource( file = file, runId = runId )
  
  # save and change workingdirectory
  cat(sprintf("initial wd: %s\n", initial_wd))
  initial_wd <- getwd()
  cat(sprintf("set wd to: %s\n", dirname(file)))
  setwd(dirname(file))
  
  # initiate packrat package installation
  require("packrat")
  #source( paste0(dirname(file), "/packrat/init.R") )
  packrat::restore()
  
  # start timing benchmark
  B_start <- as.numeric( Sys.time() )
  try( source( file, local = .ExEnv , chdir = TRUE) )
  B_end <- as.numeric( Sys.time() )
  
  # set of packrat
  
  
  #restore workingdirectory
  cat("disable packrat\n")
  packrat::disable()
  cat("detach packrat\n")
  detach("package:packrat", unload=TRUE)
  cat("restore wd\n")
  setwd(initial_wd)
  
  # add BENCHMARK timing to timings of the script (and its components)
  setTiming(process ="BENCHMARK", start = B_start, end = B_end)
  
  # add BENCHMARK timing to all other benchmarks stored in ExecEnvironment$BENCHMARKS
  setBenchmark()
  
  # get all recorded benchmarks & return the last benchmark result
  benchmark <- benchGetter( target = "benchmarks" )
  return( benchmark$time[ nrow(benchmark) ] )
}