library("hamcrest")

timed_functions <- data.frame(
  timed_fun = c(
    "write.table","write.csv","write.csv2","write.delim2","read.table","read.csv"
    ),
  package = c(
    "utils","utils","utils","utils","utils","utils"
    ),
  category = c(
    "WRITE","WRITE","WRITE","WRITE","READ","READ"
    ),
  type = c(
    "IO", "IO", "IO", "IO", "IO", "IO"
  ),
  stringsAsFactors=FALSE
)

benchmarkSource(file = "./test.R", timed_fun = timed_functions)

benchmarkSource(file = "./test.R")

benchmarkSource(file = "./test_kshjhgdhsagjh.R")

benchGetter("allprofiles")

benchGetter("allbenchmarks")
