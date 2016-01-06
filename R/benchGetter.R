benchGetter <- function(type, indexCol = NULL, returnCol = NULL, selectValue = NULL, selectedRunId = NULL, file = NULL){

  type = tolower(type)

  if (type == "id"){
    # Generated a unique ID for each benchmark run using date, time, and a random number
    # returns String '8 digit date + . + 6 digit time + . + 2 digit random number'
    cat("\nGenerating a unique ID...\n")
    exactTime <- format(Sys.time(), "%Y%m%d.%H%M%S.")
    randomNum <- sample(10:99, 1)
    id <- paste0(exactTime,randomNum)
    return(id)
  }


  if (type == "allprofiles"){
    # This function returns all records from ExecEnvironment$PROFILES table
    return(ExecEnvironment$PROFILES)
  }


  if (type == "allbenchmarks"){
    # Returns table with all recorded benchmarks
    return(ExecEnvironment$BENCHMARKS)
  }


  if (type == "profile"){
    # This function returns 'returnCol' from ExecEnvironment$PROFILES
    # where the value of 'indexCol' is identical to 'selectValue'
    if(is.null(indexCol) | is.na(indexCol) | is.nan(indexCol) |
       is.null(returnCol) | is.na(returnCol) | is.nan(returnCol) |
       is.null(selectValue) | is.na(selectValue) | is.nan(selectValue)){
      cat("\nNo or empty indexCol/returnCol/selectValue provided for subsetting PROFILES.\n")
      return(NULL)
    }
    return(ExecEnvironment$PROFILES[ExecEnvironment$PROFILES[indexCol] == selectValue, returnCol])
  }


  if(type == "profilerun"){
    # subset PROFILES table with 'runId'
    if(is.null(selectedRunId) | is.na(selectedRunId) | is.nan(selectedRunId)){
      cat("\nNo or empty selectedRunId provided for calculating the running time.\n")
      return(NULL)
    }
    
    select_run <- ExecEnvironment$PROFILES[,grep('runId',colnames(ExecEnvironment$PROFILES))] == selectedRunId
    run <- ExecEnvironment$PROFILES[select_run,]
    return(run)
  }


  if (type == "warnings"){
    # returns ExecEnvironment$WARNINGS data.frame containing all warnings recorded
    return(ExecEnvironment$WARNINGS)
  }


  if (type == "systemid"){
    # get the unique systemId that is used to identify this system
    return(ExecEnvironment$META$systemId[1])
  }


  if (type == "usedpackages"){
    # Identifies all used libraries within input file/script
    # detect all library("package") or require("package"), and
    # extract the package names
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
    return(usedPackagesNames)
  }
}
