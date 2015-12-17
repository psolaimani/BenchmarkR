# Generate and store systemId and system information
setSystemID()

benchmarkSource <- function(file) {
  runId <- getId()
  assign("file", file, envir = BenchmarkEnvironment)
  assign("runId", runId, envir = BenchmarkEnvironment)

  checkSource(file,runId)

  B_start <- as.numeric(Sys.time())
  source(file, local = ExecEnvironment)
  B_end <- as.numeric(Sys.time())

  setTiming(p="BENCHMARK", s=B_start, e=B_end)
  setBenchmark()
  benchmark <- getAllBenchmarks()
  benchmark
  return(benchmark)
}
