# Profile Factory
# This allows easy addition of functions to be timed by command
# addProfiler(timed_fun, package, category)
#   timed_fun:  function to be timed
#   package:    name of the package that contains this timer
#   category:   name for process category that should be used in profile eg READ, WRITE, ...

ProfileFactory <- function(timed_fun, package, category, con){
  # This function writes the necessary lines for timing a function to
  # a R file that will be sources to override the functions locally.
  # The added lines will be of format:
  #
  #   BenchmarkEnvironment$read.table <- function(...){
  #     start <- as.numeric(Sys.time())
  #     utils::read.table(...)
  #     end <- as.numeric(Sys.time())
  #     duration <- end - start
  #     setTiming(p="READ", s=start, e=end)
  #   }
  #


  writeLines(
    c(
      paste0("BenchmarkEnvironment$",timed_fun," <- function(...){"),
      "  start <- as.numeric(Sys.time())",
      paste0("  ",package,"::",timed_fun,"(...)"),
      "  end <- as.numeric(Sys.time())",
      "  duration <- end - start",
      paste0("  setTiming(p=\"",category,"\", s=start, e=end)"),
      "}",
      " "
    ),
    sep = "\n",
    con = con
  )

  cat(sprintf("\nwrote timed function: %s\n",paste0(package,"::",timed_fun,"(...)")))
}

addProfiler <- function(timed_functions=NULL){
  # Generates profilers from dataframe and writes to timedFunctions.R
  # timed_functions is a data.frame of format:
  # data.frame(
  #   timed_fun = character() # function to be timed
  #   package = character()   # package containing this function
  #   category = character()  # category name used in profile stats eg READ, WRITE,
  # )
  if(is.null(timed_functions)){
    return(NULL)
  } else if(class(timed_functions)!="data.frame" |
            nrow(timed_functions) == 0 |
                 ncol(timed_functions) != 3){
    cat("\nProvided functions to be timed are not in correct data.frame format!\n")
    cat("No profiling will be performed.\n")
    cat("To profile functions please provide a 3 column data.frame with:\n")
    cat("COLUMN1: name of function\n")
    cat("COLUMN2: package name\n")
    cat("COLUMN3: category name to assign\n")
    cat("structure provided data:\n\n")
    str(timed_functions)
    cat("\n\nclass provided data:\n\n")
    print(class(timed_functions))
    return(NULL)
  }

  if(!file.exists("R/timedFunctions.R")){
    file.create("R/timedFunctions.R")
  }

  con <- file("R/timedFunctions.R", "at")
  for(i in 1:nrow(timed_functions)){
    ProfileFactory(timed_functions[i,1], timed_functions[i,2], timed_functions[i,3], con)
  }
  close(con)

  source("R/timedFunctions.R")
}



