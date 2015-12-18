# download functions

BenchmarkEnvironment$download.file <- function(...){
  start <- as.numeric(Sys.time())
  utils::download.file(...)
  end <- as.numeric(Sys.time())
  setTiming(p="DOWNLOAD", s=start, e=end)
}

BenchmarkEnvironment$curlGetHeaders <- function(...){
  start <- as.numeric(Sys.time())
  base::curlGetHeaders(...)
  end <- as.numeric(Sys.time())
  setTiming(p="DOWNLOAD", s=start, e=end)
}
