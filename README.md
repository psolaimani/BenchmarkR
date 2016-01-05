# benchmaRk
[![Build Status](https://travis-ci.org/psolaimani/benchmaRk.svg?branch=master)](https://travis-ci.org/psolaimani/benchmaRk)
[![codecov.io](https://codecov.io/github/psolaimani/benchmaRk/coverage.svg?branch=master)](https://codecov.io/github/psolaimani/benchmaRk?branch=master)
a simple benchmark/profiling tool for R scripts.

**Usage:**

	benchmarkSource("/location/of/R/script.R")

installs all packages used by the script

returns the runningtime of the R script provided

prints the benchmarking details to the console

	benchmarkSource("/location/of/R/script.R", dt)
	# dt is a data.frame that contains packages/functions that should be profiled
	# columns: timed_function, package_name, category, type
	# example: 
	#	dt <-	data.frame(
	#				timed_function = c("fread"), 
	#				package_name = c("data.table"), 
	#				category = c("READ"), 
	#				type = c("IO")
	#		)

functions as previous example but times the provided functions and outputs/returns runningtime of the
script minus timed used by profiled functions.
