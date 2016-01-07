for(i in 1:100){
  rnorm(100)
}

cat("1st data read\n")
dt <- utils::read.table(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t",dec=".")
head(dt)[1,1]
print(tail(dt)[1,1])

for(i in 1:200){
  rnorm(200)
}

cat("2nd data read\n")
dt <- read.table(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"))
head(dt)[1,1]
tail(dt)[1,1]

cat("3rd data read\n")
dt <- read.csv(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

cat("4th data read\n")
dt <- read.csv2(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

cat("5th data read\n")
dt <- utils::read.delim(system.file("inst/extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

cat("6st data read\n")
dt <- read.delim2(system.file("extdata", "RNAseq2.txt", package = "benchmarkR"),sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

for(i in 1:1000){
  rnorm(500)
}
