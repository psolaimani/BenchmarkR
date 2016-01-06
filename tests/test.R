for(i in 1:100){
  rnorm(100)
}

dt <- utils::read.table("../data/RNAseq2.txt",sep="\t",dec=".")
head(dt)[1,1]
tail(dt)[1,1]

for(i in 1:200){
  rnorm(200)
}

dt <- read.table("../data/RNAseq2.txt",sep="\t",dec=".")
head(dt)[1,1]
tail(dt)[1,1]

dt <- read.csv("../data/RNAseq2.txt",sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

dt <- read.csv2("../data/RNAseq2.txt",sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

dt <- utils::read.delim("../data/RNAseq2.txt",sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

dt <- read.delim2("../data/RNAseq2.txt",sep="\t")
head(dt)[1,1]
tail(dt)[1,1]

for(i in 1:1000){
  rnorm(500)
}
