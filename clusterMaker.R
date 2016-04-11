library(amap)
library(magrittr)
library(parallel)

#--------------------------------------------

#custom zip function...
zipper <- function(xsDescribe, xs, ysDescribe, ys) {
  stopifnot(length(xs) == length(ys))
  zippedArgs <- mapply(c, xs, ys)
  row.names(zippedArgs) <- c(xsDescribe, ysDescribe)
  do.call(c, apply(zippedArgs, 2, list))
}

plot.single <- function(data, index, col, limitsForVerticalPlot) {
  plot(1:4, data[index, ], lwd=2, type='o', xlab="", ylab="", col=col, xaxt='n', yaxt='n', ylim = limitsForVerticalPlot)
  par(new=T)
}

#define a function closure for easier plotting
plot.gen <- function(specificCluster, rangeOfCluster, elementsInCluster, relevanClusterIndices, col, dir.name) {
  function(type, data) {
    limitsForVerticalPlot <- if(type == 'Raw') c(rangeOfCluster[1], rangeOfCluster[2]) else c(0, 1)
    png(paste0(dir.name, sprintf("%s.cluster.%d.png", type, specificCluster)))
    plot(0, type = "n", main=sprintf("%s cluster %d ; %d components", type, specificCluster, elementsInCluster), xlab = "", ylab = "", xlim = c(1,4), ylim = limitsForVerticalPlot)
    par(new=T)
    lapply(relevanClusterIndices, plot.single, data=data, col=col, limitsForVerticalPlot=limitsForVerticalPlot)
    dev.off()
  }
}

plotSpecificCluster <- function(clustAndCol) {

  specificCluster <- clustAndCol[["n"]] %>% as.integer
  col <- clustAndCol[["col"]]

  relevanClusterIndices <- clusters[clusters == specificCluster] %>% names %>% as.integer

  rangeOfCluster <- df[relevanClusterIndices, ] %>% range
  elementsInCluster <- length(relevanClusterIndices)

  dir.name <- sprintf("dir.cluster.%d.plots/", specificCluster)
  dir.create(dir.name)
  general.plotter <- plot.gen(specificCluster, rangeOfCluster, elementsInCluster, relevanClusterIndices, col, dir.name)
  general.plotter('Raw', df)
  general.plotter('Scaled', scaled.df)
}

#--------------------------------------------

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

#color palette
#http://tools.medialab.sciences-po.fr/iwanthue/

requiredClusters <- list(5, 10, 15, 20)
colorPalette <- list('#CC6D39', '#7889C6', '#6FAB4C', '#CC5B9B')

mclapply(zipper("n", requiredClusters, "col", colorPalette), plotSpecificCluster, mc.cores=4)
#--------------------------------------------
