library(benchmaRk)
for(i in 1:100){
  rnorm(100)
}

read.table("tests/RNAseq2.txt",sep="\t",dec=".")

for(i in 1:200){
  rnorm(200)
}

x <- read.table("tests/RNAseq2.txt",sep="\t",dec=".")

y <- read.csv("tests/RNAseq2.txt")

write.csv2(y, "tests/RNAseq2.csv2")
file.remove("tests/RNAseq2.csv2")

write.table(x, "tests/RNAseq2.table")
file.remove("tests/RNAseq2.table")

for(i in 1:1000){
  rnorm(500)
}
