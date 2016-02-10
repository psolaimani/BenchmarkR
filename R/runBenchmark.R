#' runBenchmark
#' @description This function extracts benchmark information, and downloads the necessary data/packages
#' @param bench_loc location of directory with subdirectories containing benchmarks
#' @param timed_fun data.frame with functions to be profiled
#' @export
runBenchmark <- function(runs = 1){
  
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
  
  f <- "BENCHMARK.dcf"
  Name <- na.omit( read.dcf( f , fields = c('Name') ) )[1]
  Description <- na.omit( read.dcf( f , fields = c('Description') ) )[1]
  File <- na.omit( read.dcf( f , fields = c('File') ) )
  Source <- na.omit( read.dcf( f , fields = c('Source') ) )
  Hash <- na.omit( read.dcf( f , fields = c('Hash') ) )
    
    
  if ( length(File) > 0 ) {
    
    Prepare_data <- mapply(isPresent, File, Hash, Source)
      
    if ( any(as.vector(Prepare_data) == "ERROR") ){
      warning("\nCheck data: datasets not correct/complete!\n")
    } else {
      cat("\nCheck data: correct datasets available.\n")
    }
   
  } else {
    cat("\nBenchmark doesn't contain datasets.\n")
  }
  
  # Get R script filename
  bench_file <- list.files(path = ".", pattern = ".R$")[1]
  
  # Read profiling information if available
  if (file.exists("FUNCTION.PROFILE")) {
    timed_fun <- read.table("FUNCTION.PROFILE", stringsAsFactors = FALSE)
  } else {
    timed_fun <- NULL
  }
  
  # benchmark R script with/without profiler
  benchmarkSource(bench_file, timed_fun, runs)
  
}