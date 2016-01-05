library(stringr)
library(benchmaRk)
for(i in 1:100){
  rnorm(100)
}

read.table("RNAseq2.txt",sep="\t",dec=".")

for(i in 1:200){
  rnorm(200)
}

x <- read.table("RNAseq2.txt",sep="\t",dec=".")

y <- read.csv("RNAseq2.txt")

write.csv2(y, "RNAseq2.csv2")
file.remove("RNAseq2.csv2")

write.table(x, "RNAseq2.table")
file.remove("RNAseq2.table")

for(i in 1:1000){
  rnorm(500)
}
