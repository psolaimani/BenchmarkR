#' runBenchmark
#' @description This function extracts benchmark information, and downloads the necessary data/packages
#' @param bench_loc location of directory with subdirectories containing benchmarks
#' @param timed_fun data.frame with functions to be profiled
#' @export
runBenchmark <- function(bench_loc, timed_fun=NULL){
  
  list.dirs <- function(path=NULL, pattern=NULL, all.dirs=FALSE, full.names=FALSE, ignore.case=FALSE) {
    # From answer by Joshua Ulrich: 
    # http://stackoverflow.com/questions/4749783/how-to-obtain-a-list-of-directories-within-a-directory-like-list-files-but-i
    # use full.names=TRUE to pass to file.info
    all <- list.files(path, pattern, all.dirs,
                      full.names=TRUE, recursive=FALSE, ignore.case)
    dirs <- all[file.info(all)$isdir]
    # determine whether to return full names or just dir names
    if(isTRUE(full.names))
      return(dirs)
    else
      return(basename(dirs))
  }
  
  isPresent <- function(Name,Hash,Source,Dir){
    File <- file.path(Dir,Name)
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
  
  bds <- list.dirs(path=bench_loc)
  print(bds)
  for (bd in bds){
    f <- file.path(bench_loc,bd,"/BENCHMARK.dcf")
    Name <- na.omit( read.dcf( f , fields = c('Name') ) )[1]
    Description <- na.omit( read.dcf( f , fields = c('Description') ) )[1]
    File <- na.omit( read.dcf( f , fields = c('File') ) )
    Source <- na.omit( read.dcf( f , fields = c('Source') ) )
    Hash <- na.omit( read.dcf( f , fields = c('Hash') ) )
    
    
    if ( length(File) > 0 ) {
      location <- file.path(bench_loc,bd)
      Prepare_data <- mapply(isPresent, File, Hash, Source, Dir=location)
      
      if ( any(as.vector(Prepare_data) == "ERROR") ){
        warning("\nDownload and or validation of data was not successful!\nBenchmark script might not run as expected\n")
      } else {
        cat("\nCorrect datasets found.\n")
      }
        
    } else {
      cat("\nBenchmark doesn't contain datasets.\n")
    }
    
    
    #bf <- paste0(bd,"/packrat/packrat.lock")
    #bPKG <- read.dcf( bf , fields = c('Package') )
    #bVER <- read.dcf( bf , fields = c('Version') )
    #bSRC <- read.dcf( bf , fields = c('Source') )
    
    bench_file <- file.path(bench_loc,bd,paste0(bd,".R"))
    
    print(bench_file)
    
    benchmarkSource(bench_file, timed_fun, bench_name=Name)
    
  }
  
}