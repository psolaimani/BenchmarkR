getId <- function(){
  # Generated a unique ID for each benchmark run using date, time, and a random number
  # returns String '8 digit date + . + 6 digit time + . + 2 digit random number'
  exactTime <- format(Sys.time(), "%Y%m%d.%H%M%S.")
  randomNum <- sample(10:99, 1)
  id <- paste0(exactTime,randomNum)
  return(id)
}

getAllTimings <- function(){
  # This function returns all records from ExecEnvironment$TIMINGS table
  return(ExecEnvironment$TIMINGS)
}

getAllBenchmarks <- function(){
  # Returns table with all recorded benchmarks
  return(ExecEnvironment$BENCHMARKS)
}

getTiming <- function(indexCol, returnCol, selectValue){
  # This function returns 'returnCol' from ExecEnvironment$TIMINGS
  # where the value of 'indexCol' is identical to 'selectValue'
  return(ExecEnvironment$TIMINGS[ExecEnvironment$TIMINGS[indexColumn] == selectValue, returnCol])
}

getTimeRun <- function(runId){
  # subset TIMINGS table with 'runId'
  return(subset(ExecEnvironment$TIMINGS, runId == runId))
}

getWarnings <- function(){
  # returns ExecEnvironment$WARNINGS data.frame containing all warnings recorded
  return(ExecEnvironment$WARNINGS)
}

getSystemID <- function(){
  # get the unique systemId that is used to identify this system
  return(ExecEnvironment$META$systemId[1])
}

getUsedLibs <- function(file){
  # Identifies all used libraries within input file/script
  # detect all library("package") or require("package"), and
  # extract the package names
  require(stringr)
  lines <- readLines(file)
  # make a vector of lines with library( or require(
  usedLibrary <- as.vector(
    na.omit(str_extract(lines, "(library|require)\\(.*"))
  )
  extractLibrary <- c(character(0))
  for(i in 1:length(usedLibrary)){
    # extract the package name from library(package) and remove
    # the optional ' or " characters around package name
    currentLib <- sub("(library|require)\\({1}(\"|\')*([[:alnum:]]*)(\"|\')*\\){1}",
                      "\\3", usedLibrary[i], perl = TRUE)
    extractLibrary <- c(extractLibrary,currentLib)
  }
  return(extractLibrary)
}
