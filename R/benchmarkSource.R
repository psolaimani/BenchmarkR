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
benchmarkSource <- function(file, timed_fun = NULL, runs) {
  
  # check if provided file exists
  if(!file.exists(file)){
    warning(sprintf("\nDoesn't exists: %s\n", file))
    return(NULL)
  }
  # save file name to .BenchEnv
  assign( "file", file, envir = .BenchEnv )
  
  # initiate packrat package installation
  require("packrat")
  packrat::restore()
  
  # generate and set system id if its not generated 
  setSystemID()
  
  # get a unique ID to identify this benchmark save runId  to .BenchEnv for
  # use by setter/getter/etc functions
  runId <- benchGetter(target = "Id")
  assign( "runId", runId, envir = .BenchEnv )
  
  
  # get version, (file md5 or git commit hash SHA1)
  bench_version <- benchGetter(target = "bench_version")
  assign( "bench_version", bench_version, envir = .BenchEnv )

  # load all timed functions in BenchmarkEnvironment
  addProfiler(timed_fun)
  
  cat(sprintf("runId:  \t%s\nsystemId:\t%s\n",benchGetter(target = "runid"),benchGetter(target = "systemid")))
  
  ####################################################################################
  ######## check source for direct (::) function calls ###############################
  ####################################################################################
  cat("\nChecking for direct calls in code...\n")
  direct_calls_detected <- 0
  content <- readLines( file )
  lineOfDirectCalls <- grep( "(::|:::)", content )
  direct_calls_detected <- length( lineOfDirectCalls )
  cat( sprintf("Number of direct calls detected: %i\n", direct_calls_detected) )
  cat( sprintf("\tLine[%i]: %s\n", lineOfDirectCalls, content[ lineOfDirectCalls ]) )
  ####################################################################################
  
  # warmup runs
  if (runs > 1){
    runs <- runs - 1
    run <- 0
    while (run < runs){
      try( source( file, local = .ExEnv , chdir = TRUE) )
      run <- run + 1
    }
  }
  
  
  # start timing benchmark
    B_start <- as.numeric( Sys.time() )
  try( source( file, local = .ExEnv , chdir = TRUE) )
  B_end <- as.numeric( Sys.time() )
  
  # add BENCHMARK timing to timings of the script (and its components)
  setTiming(process ="BENCHMARK", start = B_start, end = B_end, compute = FALSE)
  
  # add BENCHMARK timing to all other benchmarks stored in ExecEnvironment$BENCHMARKS
  if (!is.null(timed_fun)) {
    setTiming(process ="COMPUTE_TIME", start = B_start, end = B_end)
  }
  
  # get all recorded benchmarks & return the last benchmark result
  benchmark <- benchGetter( target = "benchmarks" )
  return( benchmark$time[ nrow(benchmark) ] )
}