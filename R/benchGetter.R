#' benchGetter
#' @description Retrieve different saved records or benchmark information
#' @param target which information to retrieve 
#'    \code{*id*}: generates a unique ID based on date/time and a random number. 
#'    \code{*profiles*}: returns all records of PROFILES table. 
#'    \code{*benchmarks*}: returns table with all recorded benchmarks. 
#'    \code{profile}: returns 'returnCol' from PROFILES where 'indexCol' == 'selectValue'. 
#'    \code{profilerun}: returns PROFILES table subsetted with \code{runId}. 
#'    \code{warnings}: returns ExecEnvironment$WARNINGS data.frame containing all warnings recorded. 
#'    \code{systemid}: returns the unique systemId that is used to identify this system. 
#'    \code{usedpackages}: returns names of all used/loaded packages within provided input file/script. 
#'    \code{allpackageversions}: returns a dataframe with packages names and version installed on current system. 
#' @param indexCol profiling records will be filtered based on content of this column
#' @param returnCol content of this column will be returned after filtering
#' @param selectValue this value will be compared to \code{indexCol} to filter profiling records
#' @param selectedRunId which \code{runId} to use for filtering profiling records
#' @param file packages used in this file will be extracted and installed
#' @importFrom stringr str_extract
#' @importFrom utils installed.packages
#' @export
benchGetter <- function(target, indexCol = NULL, returnCol = NULL, selectValue = NULL, selectedRunId = NULL, file = NULL){

  target = tolower(target)

  if (target == "id"){
    cat("\nGenerating a unique ID...\n")
    exactTime <- format(Sys.time(), "%y%m%d%H%M%S")
    randomNum <- sample(100000:999999, 1)
    id <- as.character(paste0(exactTime,randomNum))
    return(id)
  }

  if (target == "profiles"){
    return(ExecEnvironment$PROFILES)
  }

  if (target == "benchmarks"){
    return(ExecEnvironment$BENCHMARKS)
  }

  if (target == "profile"){
    if(is.null(indexCol)  | is.null(returnCol) |  is.null(selectValue) ){
      cat("\nRowname, columnname, or condition for subsetting Profiling data.frame is not provided.\n")
      return(NULL)
    }
    return(ExecEnvironment$PROFILES[ExecEnvironment$PROFILES[indexCol] == selectValue, returnCol])
  }

  if(target == "profilerun"){
    if(is.null(selectedRunId)){
      cat("\nNo or empty selectedRunId provided for calculating the running time.\n")
      return(NULL)
    }
    
    select_run <- ExecEnvironment$PROFILES[,grep('runId',colnames(ExecEnvironment$PROFILES))] == selectedRunId
    run <- ExecEnvironment$PROFILES[select_run,]
    return(run)
  }

  if (target == "warnings"){
    return(ExecEnvironment$WARNINGS)
  }
  
  if (target == "systemid"){
    return(ExecEnvironment$systemId)
  }
  
  if (target == "meta"){
    return(ExecEnvironment$META)
  }

  if (target == "usedpackages"){
    if(is.null(file)){
      cat("\nFile not provided, can't extract used packages.\n")
      return(NULL)
    }

    if(!file.exists(file)){
      cat(sprintf("\nProvided file '%s' does not exist!\n",file))
          return(NULL)
    }

    cat(sprintf("\nIdentifying used packages in: %s\n",file))
    scriptLines <- readLines(file)
    # make a vector of lines with library( or require(
    usedPackages <- as.vector(
      na.omit(stringr::str_extract(scriptLines, "(library|require)\\(.*"))
    )
    usedPackagesNames <- c(character(0))
    for(i in 1:length(usedPackages)){
      # extract the package name from library(package) and remove
      # the optional ' or " characters around package name
      currentPackageName <- sub("(library|require)\\({1}(\"|\')*([[:alnum:]]*)(\"|\')*\\){1}",
                                "\\3", usedPackages[i], perl = TRUE)
      usedPackagesNames <- c(usedPackagesNames,currentPackageName)
    }
    
    if (is.na(usedPackagesNames)){
      cat(sprintf("No packages found in: %s\n", file))
      return(NULL)
    }
      
    return(usedPackagesNames)
  }
  
  if (target == "allpackageversions"){
    systemPackages <- data.frame(character(0),character(0))
    systemPackages <- rbind(systemPackages, utils::installed.packages()[,c(1,3)], make.row.names=F, deparse.level = 2)
    colnames(systemPackages) <- c("component", "comp_value")
    return(systemPackages)
  }
}