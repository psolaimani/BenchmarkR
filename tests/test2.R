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

addP <- addProfiler()
assertThat(addP, equalTo(NULL))
dt <- data.frame(a=c(1,2),b=c(1,2))
addP <- addProfiler(dt)
assertThat(addP, equalTo(NULL))
dt <- data.frame(a=c(1,2),b=c(1,2),c=c(1,2),d=c(1,2))
addP <- addProfiler(dt)
assertThat(addP, equalTo(NULL))

getterReturn <- benchGetter(target = "profile")
assertThat(getterReturn, equalTo(NULL))
getterReturn <- benchGetter(target = "profilerun")
assertThat(getterReturn, equalTo(NULL))
getterReturn <- class(benchGetter(target = "warning"))
assertThat(getterReturn, equalTo("data.frame"))
getterReturn <- benchGetter(target = "usedpackages")
assertThat(getterReturn, equalTo(NULL))
getterReturn <- benchGetter(target = "usedpackages", file ="jahkjad/kjasdksd.R")
assertThat(getterReturn, equalTo(NULL))

sysId = setSystemID()
assertTrue(is.null(sysId))
benchCleaner(target = "meta")
sysId = setSystemID()
assertFalse(is.null(sysId))

