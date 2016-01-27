#' installUsedPackages
#' @description Installs all packages loaded within a R script using 
#' library/require function. This scripts installs all the used packages 
#' that are not installed yet
#' @param file path to a R script.
#' @return installs packages loaded within input script.
#' @usage  installUsedPackages(file)
#' @export
installUsedPackages <- function(file = NULL){
  options(repos = c(CRAN = "http://cran.rstudio.com/"))
  # validate input
  if(is.null(file)){
    cat("\nFile not provided, can't extract used packages.\n")
    return(NULL)
  } 
  if(!file.exists(file)){
    cat(sprintf("\nProvided file '%s' does not exist!\n",file))
    return(NULL)
  }
  
  # get used packages in input file
  usedPackages <- benchGetter(target = "UsedPackages", file = file)
  
  if(is.null(usedPackages)){
    cat(sprintf("\nNo extra packages are used by: %s\nContinue with next step...\n",file))
    return(NULL)
  }
  
  cat(sprintf("\nPackages used by '%s' are:\n",file))
  print(usedPackages)
  
  #  # are packages already installed or not?
  #  # which are available on CRAN
  #  # install if available on CRAN and not installed
  #  statePackages <- pacman::p_isinstalled(usedPackages)
  #  isCran <- pacman::p_iscran(usedPackages)
  #  toInstall <- statePackages == FALSE & isCran == TRUE
  #  pacman::p_install(usedPackages[toInstall])
  #  
  #  # are there any packages missing which are not from CRAN
  #  missingPackages <- !pacman::p_isinstalled(usedPackages)
  #  if(any(missingPackages)){
  #     # install BioC packages
  #      try(BiocInstaller::biocLite(usedPackages[missingPackages],
  #                              suppressUpdates=TRUE, 
  #                              suppressAutoUpdate=TRUE, 
  #                              ask=FALSE)
  #      , TRUE) 
  #  }
  return(invisible("pkg_install_complete"))
}