library("hamcrest")
require("benchmarkR")

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

nrow_profiles <- nrow(benchGetter("profiles")) == 0
assertFalse(nrow_profiles)
benchCleaner(target = "profiles")
nrow_profiles <- nrow(benchGetter("profiles")) == 0
assertTrue(nrow_profiles)

nrow_benchmarks <- nrow(benchGetter("benchmarks")) == 0
assertFalse(nrow_benchmarks)
benchCleaner(target = "benchmarks")
nrow_benchmarks <- nrow(benchGetter("benchmarks")) == 0
assertTrue(nrow_benchmarks)

nrow_meta <- nrow(benchGetter("meta")) == 0
assertFalse(nrow_meta)
benchCleaner(target = "meta")
nrow_meta <- nrow(benchGetter("meta")) == 0
assertTrue(nrow_meta)

nrow_warnings <- nrow(benchGetter("warnings")) == 0
assertFalse(nrow_warnings)
benchCleaner(target = "warnings")
nrow_warnings <- nrow(benchGetter("warnings")) == 0
assertTrue(nrow_warnings)