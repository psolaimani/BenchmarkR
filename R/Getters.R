getId <- function(){
  # Generated a unique ID for each benchmark run using date, time, and a random number
  # returns String '8 digit date + . + 6 digit time + . + 4 digit random number'
  exactTime <- format(Sys.time(), "%C%g%m%d.%H%M%S.")
  randomNum <- sample(1000:9999, 1)
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
