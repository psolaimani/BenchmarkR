
for(i in 1:100){
  rnorm(100)
}

read.table("/home/parham/workspace/benchmaRk/test/RNAseq2.txt",sep="\t",dec=".")

for(i in 1:200){
  rnorm(200)
}

x <- read.table("/home/parham/workspace/benchmaRk/test/RNAseq2.txt",sep="\t",dec=".")

y <- read.csv("/home/parham/workspace/benchmaRk/test/RNAseq2.txt")

write.csv2(y, "/home/parham/workspace/benchmaRk/test/RNAseq2.csv2")
file.remove("/home/parham/workspace/benchmaRk/test/RNAseq2.csv2")

write.table(x, "/home/parham/workspace/benchmaRk/test/RNAseq2.table")
file.remove("/home/parham/workspace/benchmaRk/test/RNAseq2.table")

for(i in 1:1000){
  rnorm(500)
}
