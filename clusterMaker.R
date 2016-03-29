library(amap)
library(magrittr)
library(parallel)

dst.met <- "correlation" 
met <- "average"
Ncpu <- 16

#"clean" dataset
df <- read.csv('initData.csv', header=T)

#new data.frame such that all time series will range from 0 (at the minimum) to 1 at the maximum
scaled.df <- apply(df, 1, function(x) {empMin <- min(x); empRange <- max(x) - empMin; (x - empMin) / empRange }) %>% t %>% as.data.frame

#hierachical clustering
hc <- hcluster(df[1:1000, ], method=dst.met, link=met, nbproc=Ncpu)

numberOfClusters <- 20

clusters <- cutree(hc, numberOfClusters)

plot.real <- function(index, rangeOfCluster, col, limitsForVerticalPlot) {
  plot(1:4, df[index, ], lwd=2, type='o', xlab="", ylab="", col=col, xaxt='n', yaxt='n', ylim = limitsForVerticalPlot)
  par(new=T)
}

plot.scaled <- function(index, rangeOfCluster, col, limitsForVerticalPlot) {
  plot(1:4, scaled.df[index, ], lwd=2, type='o', xlab="", ylab="", col=col, xaxt='n', yaxt='n', ylim = limitsForVerticalPlot)
  par(new=T)
}

plotSpecificCluster <- function(clustAndCol) {
  specificCluster <- clustAndCol[[1]] %>% as.integer
  relevanClusterIndices <- clusters[clusters == specificCluster] %>% names %>% as.integer
  relevantData <- df[relevanClusterIndices, ]
  rangeOfCluster <- range(relevantData)
  elementsInCluster <- dim(relevantData)[1]

  png(sprintf("cluster.%d.png", specificCluster))
  limitsForVerticalPlot = c(rangeOfCluster[1], rangeOfCluster[2])
  plot(0, type = "n", main=sprintf("Cluster %d ; %d components", specificCluster, elementsInCluster), xlab = "", ylab = "", xlim = c(1,4), ylim = limitsForVerticalPlot)
  par(new=T)
  lapply(relevanClusterIndices, plot.real, rangeOfCluster=rangeOfCluster, col=clustAndCol[[2]], limitsForVerticalPlot=limitsForVerticalPlot)
  dev.off()

  png(sprintf("cluster.scaled.%d.png", specificCluster))
  limitsForVerticalPlot = c(0, 1)
  plot(0, type = "n", main=sprintf("Scaled cluster %d ; %d components", specificCluster, elementsInCluster), xlab = "", ylab = "", xlim = c(1,4), ylim = limitsForVerticalPlot)
  par(new=T)
  lapply(relevanClusterIndices, plot.scaled, rangeOfCluster=rangeOfCluster, col=clustAndCol[[2]], limitsForVerticalPlot=limitsForVerticalPlot)
  dev.off()
}

#color palette
#http://tools.medialab.sciences-po.fr/iwanthue/

#lapply(list(c(5, '#CC6D39'), c(10, '#7889C6'), c(15, '#6FAB4C'), c(20, '#CC5B9B')), plotSpecificCluster)
#NAME THE LIST
mclapply(list(c(5, '#CC6D39'), c(10, '#7889C6'), c(15, '#6FAB4C'), c(20, '#CC5B9B')), plotSpecificCluster, mc.cores=4)
