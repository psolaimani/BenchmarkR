# Parham Solaimani
# 2015, BeDataDriven.com
# Override write functions from different packages to add timing.
# This will allow substraction of writing from the total runtime of
# the input script.
#
########### template for addition new write-functions ########
# BenchmarkEnvironment${WRITE_FUNCTION} <- function(...){
#   start <- as.numeric(Sys.time())
#   {PACKAGE}::{WRITE_FUNCTION}(...)
#   end <- as.numeric(Sys.time())
#   setTiming(p="WRITE", s=start, e=end)
# }
#

BenchmarkEnvironment$write.table <- function(...){
  start <- as.numeric(Sys.time())
  utils::write.table(...)
  end <- as.numeric(Sys.time())
  setTiming(p="WRITE", s=start, e=end)
}

BenchmarkEnvironment$write.csv <- function(...){
  start <- as.numeric(Sys.time())
  utils::write.csv(...)
  end <- as.numeric(Sys.time())
  setTiming(p="WRITE", s=start, e=end)
}

BenchmarkEnvironment$write.csv2 <- function(...){
  start <- as.numeric(Sys.time())
  utils::write.csv2(...)
  end <- as.numeric(Sys.time())
  setTiming(p="WRITE", s=start, e=end)
}

BenchmarkEnvironment$write.delim <- function(...){
  start <- as.numeric(Sys.time())
  utils::write.delim(...)
  end <- as.numeric(Sys.time())
  duration <- end - start
  setTiming(p="WRITE", s=start, e=end)
}

BenchmarkEnvironment$write.delim2 <- function(...){
  start <- as.numeric(Sys.time())
  utils::write.delim2(...)
  end <- as.numeric(Sys.time())
  duration <- end - start
  setTiming(p="WRITE", s=start, e=end)
}
