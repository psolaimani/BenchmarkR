#' benchmarkSource
#' @title Simple Benchmark/Profiling Tool For R Scripts
#' @author Parham Solaimani (Maintainer)
#' @author Maarten-Jan Kallen
#' @author Alexander Bertram
#' @keywords benchmark benchmarking profiling timing r script file
#' @description This script will benchmark the running time of the given input 
#' file. Time used by functions defined in timed_fun data frame will be 
#' subtracted from total running time. This benchmarking tools differs to
#' other benchmarking tools in that it times the running time of longer
#' R scripts in a defined environment by allowing (version)control over input
#' data, used packages and scriptfile.
#' @usage benchmarkSource(file, timed_fun, runs, loc.src, uses_packrat, bench_log, warn_log)
#' @param file R script to benchmark
#' @param timed_fun a data frame whith 4 columns. Column 1: function; column 2: 
#' package; column 3: process category eg. READ/WRITE but never BENCHMARK; 
#' column 4: function type, currently only 'IO'.
#' @param runs (integer) number of pre-runs which are not timed but serve to 
#' measure warm running time of the last run.
#' @param loc.src chracter vector containing location of CRAN like repository
#' which contains the source code (package_version.tar.gz) of 
#' used package versions
#' @param uses_packrat use if you have packified your script using packrat.
#' Default is TRUE
#' @param bench_log filename to use to store message/warning/errors.
#' Default is "benchmark.log"
#' @param warn_log level of logging to use (choose from -1, "INFO", "WARN", 
#' "STOP". Default value is -1.
#' @return returns a dubble with running time of last benchmark
#' @import packrat
#' @export 
benchmarkSource <- function(        file, 
                               timed_fun = NULL,
                                    runs = 0,
                                 loc.src = NULL,
                            uses_packrat = TRUE,
                               bench_log = "benchmark.log",
                                warn_log = c(-1,"INFO","WARN","STOP")) {
  
  # configure logging of the benchmark progress
  SetLogFile(bench_log)
  log_arg <- match.arg(warn_log)
  switch(log_arg,
         "-1" = options(warn = -1),
         "INFO" = options(warn = "INFO"),
         "WARN" = options(warn = "WARN"),
         "STOP" = options(warn = "STOP"),
         options(warn = -1)
  )
  
  # check if provided file exists
  stopifnot(file.exists(file))
  # save file name to .BenchEnv
  assign("file", file, envir = .BenchEnv)
  assign("runs", runs, envir = .BenchEnv)
  assign("timed_fun", timed_fun, envir = .BenchEnv)
  
  # initiate packrat package installation
  if (!is.null(loc.src)) {
    if (class(loc.src) == "character") {
      if (exists(loc.src)) {
        options( repos = c(getOption("repos"), localRepo = loc.src))
      } else {
        warning("Provided package source repository doesn't exist.")
      }
    } else {
      warning("Provided package source repository location has incorrect class.")
    }
  }
  if(uses_packrat) packrat::restore()
  
  # generate and set system id if its not generated 
  setSystemID()
  
  # get a unique ID to identify this benchmark save runId  to .BenchEnv for
  # use by setter/getter/etc functions
  runId <- benchGetter(target = "id")
  assign("runId", runId, envir = .BenchEnv)
  
  # get version, (file md5 or git commit hash SHA1)
  bench_version <- benchGetter(target = "bench_version")
  assign( "bench_version", bench_version, envir = .BenchEnv )

  # load all timed functions in BenchmarkEnvironment
  addProfiler(timed_fun)
  
  message(
    sprintf("runId:  \t%s\nsystemId:\t%s", 
            benchGetter(target = "runid"), 
            benchGetter(target = "systemid")
    )
  )
  
  ####################################################################################
  ######## check source for direct (::) function calls ###############################
  ####################################################################################
  message("Checking for direct calls in code...")
  direct_calls_detected <- 0
  content <- readLines(file)
  lineOfDirectCalls <- grep("(::|:::)", content)
  direct_calls_detected <- length(lineOfDirectCalls)
  message(sprintf("Number of direct calls detected: %i", direct_calls_detected))
  message(sprintf("\tLine[%i]: %s", lineOfDirectCalls, content[lineOfDirectCalls]))
  ####################################################################################
  
  # warmup runs
  if (runs > 0) {
    run <- 0
    while (run < runs) {
      try ( source(file, local = .ExEnv, chdir = TRUE) )
      run <- run + 1
    }
  }
  
  # start timing benchmark
  B_start <- as.numeric(Sys.time())
  run_ok <- try ( source(file, local = .ExEnv , chdir = TRUE) )
  B_end <- as.numeric(Sys.time())
  run_ok <- if(inherits(run_ok, "try-error")) "ERROR" else "OK"
  assign("run_ok", run_ok, envir = .BenchEnv)
  
  # add BENCHMARK timing to timings of the script (and its components)
  setTiming(process ="BENCHMARK", start = B_start, end = B_end, compute = FALSE)
  
  # add BENCHMARK timing to all other benchmarks stored in ExecEnvironment$BENCHMARKS
  if (!is.null(timed_fun)) {
    setTiming(process ="COMPUTE_TIME", start = B_start, end = B_end)
  }
  
  # get all recorded benchmarks & return the last benchmark result
  benchmark <- benchGetter(target = "benchmarks")
  
  benchmark$duration[nrow(benchmark)]
}