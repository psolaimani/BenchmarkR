library("hamcrest")
require("benchmarkR")


assertThat(class(benchmarkR:::BenchmarkEnvironment), equalTo("environment"))
assertThat(class(benchmarkR:::ExecEnvironment), equalTo("environment"))
assertThat(class(benchmarkR:::ExecEnvironment$PROFILES), equalTo("data.frame"))
assertThat(class(benchmarkR:::ExecEnvironment$BENCHMARKS), equalTo("data.frame"))
assertThat(class(benchmarkR:::ExecEnvironment$META), equalTo("data.frame"))
assertThat(class(benchmarkR:::ExecEnvironment$WARNINGS), equalTo("data.frame"))


assertThat(ncol(benchmarkR:::ExecEnvironment$PROFILES), equalTo(7))
assertThat(ncol(benchmarkR:::ExecEnvironment$BENCHMARKS), equalTo(4))
assertThat(ncol(benchmarkR:::ExecEnvironment$META), equalTo(3))
assertThat(ncol(benchmarkR:::ExecEnvironment$WARNINGS), equalTo(3))

assertThat(addProfiler(), equalTo(NULL))
dt <- data.frame(a=c(1,2),b=c(1,2))
assertThat(addProfiler(dt), equalTo(NULL))
dt <- data.frame(a=c(1,2),b=c(1,2),c=c(1,2),d=c(1,2))
assertThat(addProfiler(dt), equalTo(NULL))


assertThat(benchGetter(target = "profile"), equalTo(NULL))
assertThat(benchGetter(target = "profilerun"), equalTo(NULL))
assertThat(class(benchGetter(target = "warning")), equalTo("data.frame"))
assertThat(benchGetter(target = "usedpackages"), equalTo(NULL))
assertThat(benchGetter(target = "usedpackages", file ="jahkjad/kjasdksd.R"), equalTo(NULL))

sysId = setSystemID()
assertTrue(is.null(sysId))
benchCleaner(target = "meta")
sysId = setSystemID()
assertFalse(is.null(sysId))

