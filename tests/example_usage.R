timed_functions <- data.frame(
  timed_fun = c(
    "write.table","write.csv","write.csv2","write.delim2",
    "read.table","read.csv","read.csv2","read.delim","read.delim2",
    "download.file","curlGetHeaders", "fread"
    ),
  package = c(
    "utils","utils","utils","utils","utils","utils",
    "utils","utils","utils", "utils", "base", "data.table"
    ),
  category = c(
    "WRITE","WRITE","WRITE","WRITE","READ","READ",
    "READ","READ","READ", "DOWNLOAD", "DOWNLOAD", "READ"
    ),
  type = c(
    "IO", "IO", "IO", "IO", "IO", "IO",
    "IO", "IO", "IO", "IO", "IO", "IO"
  ),
  stringsAsFactors=FALSE
)

benchmarkSource(file = "test/test.R",timed_functions = timed_functions)

benchmarkSource(file = "test/test2.R",timed_functions = timed_functions)

benchmarkSource(file = "test/test.R")

benchmarkSource(file = "test/test2.R")

benchGetter("allprofiles")

benchGetter("allbenchmarks")
