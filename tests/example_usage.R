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

benchmarkSource(file = "./test.R", timed_fun = timed_functions, uses_packrat = FALSE)
benchmarkSource(file = "./test3.R", timed_fun = timed_functions, uses_packrat = FALSE)

benchmarkSource(file = "./test.R", uses_packrat = FALSE)

run <- try(benchmarkSource(file = "./test_kshjhgdhsagjh.R", uses_packrat = FALSE))
assertTrue(inherits(run, "try-error"))

benchmarkR:::benchGetter("benchmarks")

nrow_benchmarks <- nrow(benchmarkR:::benchGetter("benchmarks")) == 0
assertFalse(nrow_benchmarks)

nrow_meta <- nrow(benchmarkR:::benchGetter("meta")) == 0
assertFalse(nrow_meta)