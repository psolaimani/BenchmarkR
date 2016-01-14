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
assertTrue(is.null(addP))
dt <- data.frame(a=c(1,2),b=c(1,2))
addP <- addProfiler(dt)
assertTrue(is.null(addP))
dt <- data.frame(a=c(1,2),b=c(1,2),c=c(1,2),d=c(1,2))
addP <- addProfiler(dt)
assertTrue(is.null(addP))

getterReturn <- benchGetter(target = "profile")
assertTrue(is.null(getterReturn))
getterReturn <- benchGetter(target = "profilerun")
assertTrue(is.null(getterReturn))
getterReturn <- class(benchGetter(target = "warnings"))
assertThat(getterReturn, equalTo("data.frame"))
getterReturn <- benchGetter(target = "usedpackages")
assertTrue(is.null(getterReturn))
getterReturn <- benchGetter(target = "usedpackages", file ="jahkjad/kjasdksd.R")
assertTrue(is.null(getterReturn))

sysId = setSystemID()
assertFalse(is.null(sysId))
benchCleaner(target = "meta")
assertTrue(is.null(benchGetter(target = "meta")))

