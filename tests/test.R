library(stringr)
library(benchmarkR)
for(i in 1:100){
  rnorm(100)
}


utils::read.table("./RNAseq2.txt",sep="\t",dec=".")


library("parallel")

for(i in 1:200){
  rnorm(200)
}


read.table("./RNAseq2.txt",sep="\t",dec=".")

read.csv("./RNAseq2.txt")

read.csv2("./RNAseq2.txt")

utils::read.delim("./RNAseq2.txt")

read.delim2("./RNAseq2.txt")

for(i in 1:1000){
  rnorm(500)
}
