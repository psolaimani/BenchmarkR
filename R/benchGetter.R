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
#' @importFrom utils installed.packages
#' @export
benchGetter <- function(target, indexCol = NULL, returnCol = NULL, selectValue = NULL, selectedRunId = NULL, file = NULL){

  target = tolower(target)

  if (target == "id"){
    # Generates a unique ID
    exactTime <- format(Sys.time(), "%y%m%d%H%M%S")
    randomNum <- sample(100000:999999, 1)
    id <- as.character(paste0(exactTime,randomNum))
    return(id)
  }

  if (target == "profiles"){
    return(.BenchEnv$PROFILES)
  }

  if (target == "benchmarks"){
    return(.BenchEnv$BENCHMARKS)
  }

  if (target == "profile"){
    if(is.null(indexCol)  | is.null(returnCol) |  is.null(selectValue) ){
      cat("\nRowname, columnname, or condition for subsetting Profiling data.frame is not provided.\n")
      return(NULL)
    }
    return(.BenchEnv$PROFILES[.BenchEnv$PROFILES[indexCol] == selectValue, returnCol])
  }

  if(target == "profilerun"){
    if(is.null(selectedRunId)){
      cat("\nNo or empty selectedRunId provided for calculating the running time.\n")
      return(NULL)
    }
    
    select_run <- .BenchEnv$PROFILES[,grep('runId',colnames(.BenchEnv$PROFILES))] == selectedRunId
    run <- .BenchEnv$PROFILES[select_run,]
    return(run)
  }

  if (target == "warnings"){
    return(.BenchEnv$WARNINGS)
  }
  
  if (target == "systemid"){
    return(.BenchEnv$systemId)
  }
  
  if (target == "runid"){
    return(.BenchEnv$runId)
  }
  
  if (target == "meta"){
    return(.BenchEnv$META)
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
    # read file
    string_vector <- readLines(file)
    # regexp to select pkg name
    pkg_regexp <- "(library|require)\\({1}(\"|\')*([[:alnum:]]*)(\"|\')*\\){1}" 
    # parse string_vector with regexp and record coordinates of occurences 
    parsed_vector <- regexpr(pkg_regexp, string_vector, perl = TRUE)
    
    # extract names from string_vector using coordinates from parsed_vector
    usedPackagesNames <- do.call( 
      rbind, 
      lapply(seq_along(string_vector), 
             function(line) {
               if(parsed_vector[line] == -1) return(NA)
               start_pos <- attr(parsed_vector, "capture.start")[line, 3]
               length_name <- attr(parsed_vector, "capture.length")[line, 3] - 1
               end_pos <- start_pos + length_name
               substr(string_vector[line], start_pos, end_pos)
             }
      )
    )
    
    usedPackagesNames <- na.omit(usedPackagesNames) # remove empty lines
    usedPackagesNames <- as.vector(usedPackagesNames) # make vector of pkg names
    filter <- duplicated(usedPackagesNames) # identify duplicated names
    usedPackagesNames <- usedPackagesNames[!filter] # filter out duplicates
    
    # when only NAs, usedPackagesNames become logical(0) empty vector
    if(class(usedPackagesNames) == "logical") {
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