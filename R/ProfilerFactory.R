# Profiler Factory
# This allows easy addition of functions to be timed by command
# addProfiler(data.frame(timed_fun, package, category,type))
#   timed_fun:  function to be timed
#   package:    name of the package that contains this timer
#   category:   name for process category that should be used in profile eg READ, WRITE, ...
#   type:       type of function eg. IO, DB, GRAPH

factorsAsStrings <- function(data_frame){
  for (i in 1:ncol(data_frame)){
    if (class(data_frame[,i]) == "factor"){
      data_frame[,i] <- as.character(data_frame[,i])
    }
  }
  data_frame
}

ProfilerFactory <- function(fun, pkg, prc, typ) {
  
  if (typ == "IO"){
    function(...) {
      start_p <- as.numeric(Sys.time())
      res <- withVisible(do.call(getExportedValue(pkg, fun), list(...)))
      end_p <- as.numeric(Sys.time())
      duration <- end_p - start_p
      setTiming(process = prc, start = start_p, end = end_p)
      if(res$visible) res$value else invisible(res$value)
    }
  }
  
}

addProfiler <- function(timed_fun=NULL){
  if(is.null(timed_fun)){
    cat("\ndata.frame with function to be timed not provided.\n")
    return(NULL)
  } else if(class(timed_fun)!="data.frame" |
            nrow(timed_fun) == 0 |
            ncol(timed_fun) != 4){
    cat("\nProvided functions to be timed are not in correct data.frame format!\n")
    cat("No profiling will be performed.\n")
    cat("To profile functions please provide a 4 column data.frame with:\n")
    cat("COLUMN1: name of function\n")
    cat("COLUMN2: package name\n")
    cat("COLUMN3: process name to assign\n")
    cat("COLUMN4: process type (only 'IO' is implemented)\n")
    cat("structure provided data:\n\n")
    str(timed_fun)
    cat("\n\nclass provided data:\n\n")
    print(class(timed_fun))
    return(NULL)
  } else if (any(as.vector(sapply(timed_fun, function(x) class(x) )) != "character")){
    cat("\nProvided data.frame with functions contains factors!\n")
    cat("Trying to convert factor columns to character columns...\n\n")
    timed_fun <- factorsAsStrings(timed_fun)
  }
  
  if (any(as.vector(sapply(timed_fun, function(x) class(x) )) != "character")){
    cat("\nProvided data.frame with functions to profile contains non-character columns.\n")
    cat("Please correct and retry.\n\n")
    return(NULL)
  }
  
  for (i in 1:nrow(timed_fun)){
    fun <- timed_fun[i,1]
    pkg <- timed_fun[i,2]
    prc <- timed_fun[i,3]
    typ <- timed_fun[i,4]
    
    assign(
      fun,
      ProfilerFactory(fun, pkg, prc, typ),
      envir = ExecEnvironment
    )
  }
}
