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

assertThat(addProfiler(), NULL)
dt <- data.frame(a=c(1,2),b=c(1,2))
assertThat(addProfiler(dt), NULL)
dt <- data.frame(a=c(1,2),b=c(1,2),c=c(1,2),d=c(1,2))
assertThat(addProfiler(dt), NULL)


assertThat(benchGetter(target = "profile"), NULL)
assertThat(benchGetter(target = "profilerun"), NULL)
assertThat(class(benchGetter(target = "warning")), "data.frame")
assertThat(benchGetter(target = "usedpackages"), NULL)
assertThat(benchGetter(target = "usedpackages", file ="jahkjad/kjasdksd.R"), NULL)

