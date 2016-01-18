for(i in 1:100){
  rnorm(100)
}

dt <- utils::read.table(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t",dec=".")
head(dt)[1,1]
tail(dt)[1,1]

for(i in 1:100){
  rnorm(100)
}

dt <- read.table(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"))
head(dt)[1,1]
tail(dt)[1,1]

dt <- read.csv(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

dt <- read.csv2(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

dt <- utils::read.delim(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

dt <- read.delim2(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

for(i in 1:100){
  rnorm(100)
}
