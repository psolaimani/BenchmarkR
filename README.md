# benchmarkR
[![Build Status](https://travis-ci.org/psolaimani/BenchmarkR.svg?branch=master)](https://travis-ci.org/psolaimani/BenchmarkR)
[![codecov.io](https://codecov.io/github/psolaimani/BenchmarkR/coverage.svg?branch=master)](https://codecov.io/github/psolaimani/BenchmarkR?branch=master)
[![Gitter](https://badges.gitter.im/psolaimani/BenchmarkR.svg)](https://gitter.im/psolaimani/BenchmarkR?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

a simple benchmark/profiling tool for R scripts.

**Usage:**

	benchmarkSource("/location/of/R/script.R")
	benchmarkSource("/location/of/R/script.R",timed_fun = data.frame(fun,pkg,prc,typ))

installs all packages used by the script

returns the runningtime of the R script provided

prints the benchmarking details to the console

	benchmarkSource("/location/of/R/script.R", dt)
	# dt is a data.frame that contains packages/functions that should be profiled
	# columns: fun, pkg, process, type
	# example: 
	#	dt <-	data.frame(
	#				fun = c("fread"), 
	#				pkg = c("data.table"), 
	#				prc = c("READ"), 
	#				typ = c("IO")
	#		)

functions as previous example but times the provided functions and outputs/returns runningtime of the
script minus timed used by profiled functions.
