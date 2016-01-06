library(stringr)
library(benchmarkR)
for(i in 1:100){
  rnorm(100)
}

read.table("RNAseq2.txt",sep="\t",dec=".")

for(i in 1:200){
  rnorm(200)
}

x <- read.table("RNAseq2.txt",sep="\t",dec=".")

for(i in 1:200){
  rnorm(200)
}

y <- read.csv("RNAseq2.txt")

for(i in 1:200){
  rnorm(200)
}


for(i in 1:1000){
  rnorm(500)
}
