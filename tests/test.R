library(benchmaRk)
for(i in 1:100){
  rnorm(100)
}

library(utils)

utils::read.table("/home/parham/workspace/benchmaRk/test/RNAseq2.txt",sep="\t",dec=".")

library(data.table)
fread("/home/parham/workspace/benchmaRk/test/RNAseq2.txt")

library("parallel")

for(i in 1:200){
  rnorm(200)
}

require(plyr)

require('cluster')

read.table("/home/parham/workspace/benchmaRk/test/RNAseq2.txt",sep="\t",dec=".")

read.csv("/home/parham/workspace/benchmaRk/test/RNAseq2.txt")

read.csv2("/home/parham/workspace/benchmaRk/test/RNAseq2.txt")

utils::read.delim("/home/parham/workspace/benchmaRk/test/RNAseq2.txt")

read.delim2("/home/parham/workspace/benchmaRk/test/RNAseq2.txt")

for(i in 1:1000){
  rnorm(500)
}
