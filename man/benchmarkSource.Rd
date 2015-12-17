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
}

\seealso{
}

\examples{
benchmarkSource("test/test.R")
replicate(10, benchmarkSource("test/test2.R"))

## The function is currently defined as
function (file)
{
    runId <- getId()
    assign("file", file, envir = BenchmarkEnvironment)
    assign("runId", runId, envir = BenchmarkEnvironment)
    checkSource(file, runId)
    B_start <- as.numeric(Sys.time())
    source(file, local = ExecEnvironment)
    B_end <- as.numeric(Sys.time())
    setTiming(p = "BENCHMARK", s = B_start, e = B_end)
    setBenchmark()
    benchmark <- getAllBenchmarks()
    benchmark
    return(benchmark)
  }
}
\keyword{ ~benchmark }
\keyword{ ~profile }
\keyword{ ~script }
