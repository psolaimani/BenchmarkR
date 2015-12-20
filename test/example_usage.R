timed_functions <- data.frame(
  timed_fun = c(
    "write.table","write.csv","write.csv2","write.delim2",
    "read.table","read.csv","read.csv2","read.delim","read.delim2",
    "download.file","curlGetHeaders"),
  package = c(
    "utils","utils","utils","utils","utils","utils",
    "utils","utils","utils", "utils", "base"),
  category = c(
    "WRITE","WRITE","WRITE","WRITE","READ","READ",
    "READ","READ","READ", "DOWNLOAD", "DOWNLOAD"),
  stringsAsFactors=FALSE
)

benchmarkSource("test/test.R",timed_functions = timed_functions)

benchmarkSource("test/test.R",timed_functions = timed_functions)

getAllTimings()

getAllBenchmarks()
