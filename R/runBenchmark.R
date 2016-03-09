#' runBenchmark
#' @description This function extracts benchmark information, and downloads the necessary data/packages. 
#' @usage runBenchmark(runs, loc.src, dcf, timedFunFile)
#' @usage runBenchmark()
#' @param runs number of runs for warming up. After warmup runs the workflow
#' will be runned one more time for timing perpose. Default is 0.
#' @param loc.src location of CRAN like repository containing the source code
#' of used package versions. Default is NULL.
#' @param dcf information about workflows name and description and 
#' datafile name, download location, md5hash in Debian Control Format. Default
#' is BENCHMARK.dcf
#' @param timedFunFile file with functions to be profiled. Default is
#' FUNCTION.PROFILE
#' @export
runBenchmark <- function(runs = 0, loc.src=NULL, dcf = "BENCHMARK.dcf", timedFunFile = "FUNCTION.PROFILE"){
  
  isPresent <- function(Name,Hash,Source){
    File <- file.path(Name)
    cat(sprintf("processing: %s\n", File))
    if (file.exists(File) == FALSE) {
      warning(sprintf("%s doesn't exist.\n", Name ))
      n=1
      Try=TRUE
      while ( n < 4 & Try == TRUE){
        cat( sprintf("Downloading file. Try %i out of 3...\n", n) )
        try( download.file(Source, File), TRUE )
        n <- n+1
        if (file.exists(File) == TRUE){ 
          fHash <- tools::md5sum(File)
          if(fHash == Hash) { 
            Try <- FALSE 
          }
        }
      }
      
      if (file.exists(File) == FALSE) {
        warning(sprintf("Couldn't download %s.\n",Name))
        return("ERROR")
      }
      
      fHash <- tools::md5sum(File)
      if ( fHash != Hash ){
        warning(sprintf("%s md5sum is still incorrect\nPlease correct dcf info.\n", Name))
        return("ERROR")
      } else {
        return("READY")
      }
      
    } else {
      fHash <- tools::md5sum(File)
      if (fHash != Hash){
        warning(sprintf("%s has incorrect md5sum!\n", File))
        try(file.remove(File),TRUE)
        n=1
        Try=TRUE
        while ( n < 4 & Try == TRUE){
          cat( sprintf("Downloading and overwriting file. Try %i out of 3...\n", n) )
          try( download.file(Source, File), TRUE )
          n <- n+1
          if (file.exists(File) == TRUE){ 
            fHash <- tools::md5sum(File)
            if(fHash == Hash) { 
              Try <- FALSE 
              cat(sprintf("Download %s completed.\n", Name))
            }
          }
        }
        fHash <- tools::md5sum(File)
        if ( fHash != Hash ){
          warning(sprintf("%s md5sum is still incorrect\nPlease correct dcf info.\n", Name))
          return("ERROR")
        } else {
          return("READY")
        }
      } else {
        cat(sprintf("md5sum data file is correct.\n", Name))
        return("READY")
      }
    }
  }
  
  Name        <- na.omit(read.dcf(dcf, fields = c('Name')))[1]
  Description <- na.omit(read.dcf(dcf, fields = c('Description')))[1]
  File        <- na.omit(read.dcf(dcf, fields = c('File')))
  Source      <- na.omit(read.dcf(dcf, fields = c('Source')))
  Hash        <- na.omit(read.dcf(dcf, fields = c('Hash')))
  
    
  if (length(File) > 0) {
    Prepare_data <- mapply(isPresent, File, Hash, Source)
    if (any(as.vector(Prepare_data) == "ERROR")){
      warning("\nCheck data: datasets not correct/complete!\n")
    } else {
      cat("\nCheck data: correct datasets available.\n")
    }
  } else {
    cat("\nBenchmark doesn't contain datasets.\n")
  }
  
  # Get R script filename
  wd         <- normalizePath("./")
  file_name  <- paste0(tail(strsplit(wd,"/")[[1]],n=1),".R")
  bench_file <- file.path(wd, file_name)
  
  # Read profiling information if available
  if (file.exists(timedFunFile)) {
    timed_fun <- read.table(timedFunFile, stringsAsFactors = FALSE)
  } else {
    timed_fun <- NULL
  }
  
  # benchmark R script with/without profiler
  benchmarkSource(file = bench_file, timed_fun = timed_fun, runs = runs, loc.src = loc.src)
  
}