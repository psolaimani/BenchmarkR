\name{benchmarkSource}
\alias{benchmarkSource}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
benchmarkSource()
}
\description{
Reports time used for computations within a script by substracting the
reading/writing time from total running time.
}
\usage{
benchmarkSource(file)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{file }{name of the R script that needs to be benchmarked.}
}

\details{
}

\value{
returns data.frame with timing information: runId, file, time
\item{runId }{A unique id is assigned to each benchmarking call using getId() function. This ID is used throughout the package for setting/getting information for each benchmark run.}
\item{file }{Name of the R script being benchmarked (input argument of benchmarkSource() function).}
\item{time }{Running time input R script were read/write time are substracted.}
}

\references{
}

\author{
Parham Solaimani, Maarten-Jan Kallen, Alexander Bertram
}

\note{
Undocumented code objects:
  ‘BenchmarkEnvironment’ ‘ExecEnvironment’ ‘ProfilerFactory’
  ‘addProfiler’ ‘benchCleaner’ ‘benchGetter’ ‘calcComputeTime’
  ‘checkSource’ ‘factorsAsStrings’ ‘installUsedPackages’ ‘setBenchmark’
  ‘setSystemID’ ‘setTiming’
}

\seealso{
}

\examples{
benchmarkSource("test/test.R")
replicate(10, benchmarkSource("test/test2.R"))

## The function is currently defined as
    function(...) {
      start_p <- as.numeric(Sys.time())
      res <- withVisible(do.call(getExportedValue(pkg, fun), list(...)))
      end_p <- as.numeric(Sys.time())
      duration <- end_p - start_p
      setTiming(process = prc, start = start_p, end = end_p)
      if(res$visible) res$value else invisible(res$value)
    }
}
\keyword{ ~benchmark }
\keyword{ ~benchmarking }
\keyword{ ~profile }
\keyword{ ~profiling }
\keyword{ ~script }
\keyword{ ~R }
\keyword{ ~R script }
