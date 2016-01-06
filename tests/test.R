library(stringr)
library(benchmarkR)
for(i in 1:100){
  rnorm(100)
}


dt <- utils::read.table("./RNAseq2.txt",sep="\t",dec=".")
head(dt)
tail(dt)

library("parallel")

for(i in 1:200){
  rnorm(200)
}


dt <- read.table("./RNAseq2.txt",sep="\t",dec=".")
head(dt)
tail(dt)

dt <- read.csv("./RNAseq2.txt")
head(dt)
tail(dt)

dt <- read.csv2("./RNAseq2.txt")
head(dt)
tail(dt)

dt <- utils::read.delim("./RNAseq2.txt")
head(dt)
tail(dt)

dt <- read.delim2("./RNAseq2.txt")
head(dt)
tail(dt)

for(i in 1:1000){
  rnorm(500)
}
