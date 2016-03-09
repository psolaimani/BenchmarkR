#' factorsAsStrings
#' @description converts all Factor columns within input data.frame to Character columns
#' @param df input object
#' @return Replaces factor columns in list or data frame, otherwise returns input object as is.
#' @usage factorsAsStrings(df)
factorsAsStrings <- function(df) {
  if (is.list(df)) {
    df[] <- lapply(df, function(col) {
      if (is.factor(col)) as.character(col) else col
    })
  }
  df
}

#' ProfilerFactory
#' @description creates a new function by encapsulating input function with code neccessary for timing.
#' @param fun function to encapsulate with timing
#' @param pkg name of the package that contains this function
#' @param prc name for process category that should be used in profile eg. READ or WRITE.
#' @param typ type of function eg. IO, DB, or GRAPH. Only IO is currently implemented
#' @return new timed function based on input function
#' @usage ProfilerFactory(fun, pkg, prc, typ)
ProfilerFactory <- function(fun, pkg, prc, typ = c("IO")) {
  
  typ = match.arg(typ)
  
  res <- switch(
    typ,
    "IO" = {
      function(...) {
        start_p <- as.numeric(Sys.time())
        res <- withVisible(do.call(getExportedValue(pkg, fun), list(...)))
        end_p <- as.numeric(Sys.time())
        duration <- end_p - start_p
        setTiming(process = prc, start = start_p, end = end_p)
        if(res$visible) res$value else invisible(res$value)
      }
      res
    }
  )
}

#' addProfiler
#' @description This function loops through a data.frame with functions that need to be timed and overrides these function with a timed version of the function in ExecEnvironment.
#' @param timed_fun a data.frame containing all functions that should be timed. If empty returns NULL
#' @usage addProfiler(timed_fun)
#' @return override input functions in environment(ExecEnvironment)
#' @export
addProfiler <- function(timed_fun = NULL){
  if(is.null(timed_fun)) {
    warning("data.frame with function to be timed not provided.")
  } else if (class(timed_fun)!="data.frame" |
             nrow(timed_fun) == 0 |
             ncol(timed_fun) < 4) {
    warning(
      c("Profiler input has incorrect data frame format!\n",
        "Required a 4 column data frame:\n",
        "COLUMN1: name of function\n",
        "COLUMN2: package name\n",
        "COLUMN3: process name to assign\n",
        "COLUMN4: process type (only 'IO' is implemented)\n",
        "No profiling will be performed.\n")
    )
    
  } else if (any(as.vector(sapply(timed_fun, function(x) class(x) )) != "character")){
    warning("\nData frame with timed functions contains non character columns!\n
            Trying to convert factor columns to character columns...\n\n")
    timed_fun <- factorsAsStrings( timed_fun )
    
    if (any(as.vector(sapply(timed_fun, function(x) class(x) )) != "character")){
      warning(c("Columns could not be coerced to character\n",
                "Please correct and retry."))
      timed_fun <- NULL
    }
  }
  
  if (!is.null(timed_fun)){
    for ( i in 1:nrow(timed_fun) ){
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
}
