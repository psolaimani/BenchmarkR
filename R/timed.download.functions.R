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





base:
  file(description = "", open = "", blocking = TRUE,
       encoding = getOption("encoding"), raw = FALSE)

url(description, open = "", blocking = TRUE,
    encoding = getOption("encoding"), method)

gzfile(description, open = "", encoding = getOption("encoding"),
       compression = 6)

bzfile(description, open = "", encoding = getOption("encoding"),
       compression = 9)

xzfile(description, open = "", encoding = getOption("encoding"),
       compression = 6)

unz(description, filename, open = "", encoding = getOption("encoding"))

pipe(description, open = "", encoding = getOption("encoding"))

fifo(description, open = "", blocking = FALSE,
     encoding = getOption("encoding"))

socketConnection(host = "localhost", port, server = FALSE,
                 blocking = FALSE, open = "a+",
                 encoding = getOption("encoding"),
                 timeout = getOption("timeout"))

open(con, ...)
## S3 method for class 'connection'
open(con, open = "r", blocking = TRUE, ...)

close(con, ...)
## S3 method for class 'connection'
close(con, type = "rw", ...)

flush(con)

isOpen(con, rw = "")
isIncomplete(con)
