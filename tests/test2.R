library("hamcrest")
library("benchmarkR")


assertThat(class(benchmarkR:::BenchmarkEnvironment), "environment")
assertThat(class(benchmarkR:::ExecEnvironment), "environment")
assertThat(class(benchmarkR:::ExecEnvironment$PROFILES), "data.frame")
assertThat(class(benchmarkR:::ExecEnvironment$BENCHMARKS), "data.frame")
assertThat(class(benchmarkR:::ExecEnvironment$META), "data.frame")
assertThat(class(benchmarkR:::ExecEnvironment$WARNINGS), "data.frame")


assertThat(ncol(benchmarkR:::ExecEnvironment$PROFILES), 7)
assertThat(ncol(benchmarkR:::ExecEnvironment$BENCHMARKS), 4)
assertThat(ncol(benchmarkR:::ExecEnvironment$META), 3)
assertThat(ncol(benchmarkR:::ExecEnvironment$WARNINGS), 3)