library(amap)

dst.met <- "correlation" 
met <- "average"
Ncpu <- 16

df <- read.csv('initData.csv', header=T)

hc <- hcluster(df[1:1000, ], method=dst.met, link=met, nbproc=Ncpu)
