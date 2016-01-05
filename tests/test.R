library(benchmaRk)
for(i in 1:100){
  rnorm(100)
}

library(utils)

utils::read.table("tests/RNAseq2.txt",sep="\t",dec=".")

library(data.table)
fread("tests/RNAseq2.txt")

library("parallel")

for(i in 1:200){
  rnorm(200)
}

require(plyr)

require('cluster')

read.table("tests/RNAseq2.txt",sep="\t",dec=".")

read.csv("tests/RNAseq2.txt")

read.csv2("tests/RNAseq2.txt")

utils::read.delim("tests/RNAseq2.txt")

read.delim2("tests/RNAseq2.txt")

for(i in 1:1000){
  rnorm(500)
}
