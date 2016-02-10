library("hamcrest")
require("benchmarkR")

assertThat(class(BenchEnv), equalTo("environment"))
assertThat(class(ExEnv), equalTo("environment"))
assertThat(class(benchGetter(target = 'benchmarks')), equalTo("data.frame"))
assertThat(class(benchGetter(target = 'meta')), equalTo("data.frame"))

assertThat(ncol(benchGetter(target = 'benchmarks')), equalTo(8))
assertThat(ncol(benchGetter(target = 'meta')), equalTo(3))

addP <- addProfiler()
assertTrue(is.null(addP))
dt <- data.frame(a=c(1,2),b=c(1,2))
addP <- addProfiler(dt)
assertTrue(is.null(addP))
dt <- data.frame(a=c(1,2),b=c(1,2),c=c(1,2),d=c(1,2))
addP <- addProfiler(dt)
assertTrue(is.null(addP))
dt <- data.frame(a=c("A","B"),b=c("C","D"),c=c(1,2),d=c(1,2))
dt2 <- factorsAsStrings(dt)
assertThat(class(dt$a), equalTo("factor"))
assertThat(class(dt2$a), equalTo("character"))

replicate(3, benchmarkSource(file = "./test3.R") )
sysId <- benchGetter(target = "systemId")
sysId_prf <- benchGetter(target = "profile", indexCol = "process", selectValue = "BENCHMARK", returnCol = "systemId")[1]
isSame <- sysId == sysId_prf
assertTrue(isSame)

getterReturn <- benchGetter(target = "profile")
assertTrue(is.null(getterReturn))
getterReturn <- benchGetter(target = "profilerun")
assertTrue(is.null(getterReturn))

sysId = setSystemID()
assertFalse(is.null(sysId))

old_sysId <- benchGetter(target = "systemid")
assertTrue(nchar(old_sysId) == 32)
assign("systemId", 666, envir = benchmarkR::.BenchEnv)
setSystemID()
new_sysId <- benchGetter(target = "systemid")
assertTrue(new_sysId != 666)

update <- benchDBReport()
assertTrue(is.null(update))
update <- benchDBReport(usr = "dbuser", pwd = "dbpassword", host_address="localhost", 
                        conn_string=NULL, db_name = "benchmarkR", con_type = "mysql")
isSame <- update == "DB_UPDATED"
assertFalse(isSame)
assertTrue(is.null(update))
