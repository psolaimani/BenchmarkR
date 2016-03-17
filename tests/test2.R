library("hamcrest")
require("benchmarkR")

assertThat(class(benchmarkR:::.BenchEnv), equalTo("environment"))
assertThat(class(benchmarkR:::.ExEnv), equalTo("environment"))
assertThat(class(benchmarkR:::benchGetter(target = 'benchmarks')), equalTo("data.frame"))
assertThat(class(benchmarkR:::benchGetter(target = 'meta')), equalTo("data.frame"))

assertThat(ncol(benchmarkR:::benchGetter(target = 'benchmarks')), equalTo(10))
assertThat(ncol(benchmarkR:::benchGetter(target = 'meta')), equalTo(3))

addP <- benchmarkR:::addProfiler()
assertTrue(is.null(addP))
#dt <- data.frame(a=c(1,2),b=c(1,2))
#addP <- benchmarkR:::addProfiler(dt)
#assertTrue(is.null(addP))
#dt <- data.frame(a=c(1,2),b=c(1,2),c=c(1,2),d=c(1,2))
#addP <- benchmarkR:::addProfiler(dt)
#assertTrue(is.null(addP))
dt <- data.frame(a=c("A","B"),b=c("C","D"),c=c(1,2),d=c(1,2))
dt2 <- benchmarkR:::factorsAsStrings(dt)
assertThat(class(dt$a), equalTo("factor"))
assertThat(class(dt2$a), equalTo("character"))

replicate(3, benchmarkSource(file = "./test3.R", uses_packrat = FALSE) )
sysId <- benchmarkR:::benchGetter(target = "systemid")
sysId_prf <- benchmarkR:::benchGetter(target = "profile", idxCol = "process", fltVal = "BENCHMARK", retCol = "systemId")[1]
isSame <- sysId == sysId_prf
assertTrue(isSame)

getterReturn <- benchmarkR:::benchGetter(target = "profile")
assertTrue(is.null(getterReturn))
getterReturn <- benchmarkR:::benchGetter(target = "profilerun")
assertTrue(is.null(getterReturn))

sysId = benchmarkR:::setSystemID()
assertFalse(is.null(sysId))

old_sysId <- benchmarkR:::benchGetter(target = "systemid")
assertTrue(nchar(old_sysId) == 32)
assign("systemId", 666, envir = benchmarkR:::.BenchEnv)
benchmarkR:::setSystemID()
new_sysId <- benchmarkR:::benchGetter(target = "systemid")
assertTrue(new_sysId != 666)
assertTrue(new_sysId == old_sysId)

update <- try(benchDBReport())
assertTrue(inherits(update, "try-error"))
update <- benchDBReport(db_name = system.file("extdata", "benchmarkR.db", package = "benchmarkR"), con_type = "sqlite")
isSame <- update == "DB_UPDATED"
assertTrue(isSame)
assertFalse(is.null(update))
