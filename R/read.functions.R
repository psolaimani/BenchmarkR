# Parham Solaimani
# 2015, BeDataDriven.com
# Override read functions from different packages to add timing.
# This will allow substraction of writing from the total runtime of
# the input script.
#
########### template for addition new read-functions ########
# BenchmarkEnvironment${READ_FUNCTION} <- function(...){
#   start <- as.numeric(Sys.time())
#   {PACKAGE}::{READ_FUNCTION}(...)
#   end <- as.numeric(Sys.time())
#   setTiming(p="WRITE", s=start, e=end)
# }
#

BenchmarkEnvironment$read.table <- function(...){
  start <- as.numeric(Sys.time())
  utils::read.table(...)
  end <- as.numeric(Sys.time())
  duration <- end - start
  setTiming(p="READ", s=start, e=end)
}

BenchmarkEnvironment$read.csv <- function(...){
  start <- as.numeric(Sys.time())
  utils::read.csv(...)
  end <- as.numeric(Sys.time())
  setTiming(p="WRITE", s=start, e=end)
}

BenchmarkEnvironment$read.csv2 <- function(...){
  start <- as.numeric(Sys.time())
  utils::read.csv2(...)
  end <- as.numeric(Sys.time())
  setTiming(p="WRITE", s=start, e=end)
}

BenchmarkEnvironment$read.delim <- function(...){
  start <- as.numeric(Sys.time())
  utils::read.delim(...)
  end <- as.numeric(Sys.time())
  setTiming(p="WRITE", s=start, e=end)
}

BenchmarkEnvironment$read.delim2 <- function(...){
  start <- as.numeric(Sys.time())
  utils::read.delim2(...)
  end <- as.numeric(Sys.time())
  setTiming(p="WRITE", s=start, e=end)
}
