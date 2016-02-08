#' factorsAsStrings
#' @description converts all Factor columns within input data.frame to Character columns
#' @param data_frame input data.frame
#' @return data.frame with all factor columns converted to character columns
#' @usage factorsAsStrings(data_frame)
#' @export
factorsAsStrings <- function(data_frame){
  for (i in 1:ncol(data_frame)){
    if (class(data_frame[,i]) == "factor"){
      data_frame[,i] <- as.character(data_frame[,i])
    }
  }
  data_frame
}

#' ProfilerFactory
#' @description creates a new function by encapsulating input function with code neccessary for timing.
#' @param fun function to encapsulate with timing
#' @param pkg name of the package that contains this function
#' @param prc name for process category that should be used in profile eg. READ or WRITE.
#' @param typ type of function eg. IO, DB, or GRAPH. Only IO is currently implemented
#' @return new timed function based on input function
#' @export
#' @usage ProfilerFactory(fun, pkg, prc, typ)
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

#' addProfiler
#' @description This function loops through a data.frame with functions that need to be timed and overrides these function with a timed version of the function in ExecEnvironment.
#' @param timed_fun a data.frame containing all functions that should be timed. If empty returns NULL
#' @usage addProfiler(timed_fun)
#' @return override input functions in environment(ExecEnvironment)
#' @export
addProfiler <- function(timed_fun=NULL){
  if(is.null(timed_fun)){
    warning("\ndata.frame with function to be timed not provided.\n")
    return(NULL)
  } else if(class(timed_fun)!="data.frame" |
            nrow(timed_fun) == 0 |
            ncol(timed_fun) != 4){
    warning("\nProvided functions to be timed are not in correct data.frame format!\n")
    warning("No profiling will be performed.\n")
    warning("To profile functions please provide a 4 column data.frame with:\n")
    warning("COLUMN1: name of function\n")
    warning("COLUMN2: package name\n")
    warning("COLUMN3: process name to assign\n")
    warning("COLUMN4: process type (only 'IO' is implemented)\n")
    return(NULL)
  } else if (any(as.vector(sapply(timed_fun, function(x) class(x) )) != "character")){
    warning("\nProvided data.frame with functions contains factors!\n")
    warning("Trying to convert factor columns to character columns...\n\n")
    timed_fun <- factorsAsStrings(data_frame = timed_fun)
  }
  
  if (any(as.vector(sapply(timed_fun, function(x) class(x) )) != "character")){
    warning("\nProvided data.frame with functions to profile contains non-character columns.\n")
    warning("Please correct and retry.\n\n")
    return(NULL)
  }
  
  for (i in 1:nrow(timed_fun)){
    fun <- timed_fun[i,1]
    pkg <- timed_fun[i,2]
    prc <- timed_fun[i,3]
    typ <- timed_fun[i,4]
    
    assign(
      fun,
      ProfilerFactory(fun = fun, pkg = pkg, prc = prc, typ = typ),
      envir = .BenchEnv
    )
  }
}
