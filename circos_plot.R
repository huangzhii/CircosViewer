# Zhi Huang 04/12/2018
library(circlize)

circosPlot <- function(data, hg.number = "hg38", myTitle = "Human Genome", font.scale = 1, symbol.size = 2, line.width = 5, plot.margin = 10, line.color="pink"){
  
  genes_str <- data[,2]
  # print(genes_str)
  # import hg19 and hg38
  if(hg.number == "hg19"){
    load("./data/UCSC_hg19_refGene_20180330.Rdata") # varname: hg19
    hg <- data.frame(cbind(rownames(hg19), hg19, hg19[6]-hg19[5]))
  }
  if(hg.number == "hg38"){
    load("./data/UCSC_hg38_refGene_20180330.Rdata") # varname: hg38
    hg <- data.frame(cbind(rownames(hg38), hg38, hg38[6]-hg38[5]))
  }
  colnames(hg) = c("id","","name","chrom","strand","txStart","txEnd","cdsStart","cdsEnd","exonCount","exonStarts","exonEnds","proteinID","alignID","","","","length")
  hg.ring <- hg[!grepl("_", hg$chrom),] # remove undefined chromosome
  hg.ring <- hg.ring[!grepl("chrM", hg.ring$chrom),]
  hg.matched <- hg.ring[match(genes_str, hg.ring$alignID, nomatch = 0), ]
  hg.ring.lengthsum <- aggregate(hg.ring["length"],hg.ring["chrom"],sum)
  
  factors_count = as.data.frame(hg.ring.lengthsum)
  factors = factor(factors_count[,1], levels = factors_count[,1])
  xlim = cbind(rep(0, dim(factors_count)[1]), factors_count[,2])
  rownames(xlim) = factors_count[,1]
  BED.data <- data.frame(hg.matched[,c(4,6:7,10,14)])
  BED.data$txStart <- as.numeric(sub('.*\\:', '', data$Location ))
  BED.data$Type <- data$Type
  BED.data$Alteration <- data$Alteration
  BED.data$Drug <- data$Drug
  BED.data$Location <- data$Location
  # BED.data$IDandDrug <- paste0(data$Gene, " (", data$Drug, ")")
  BED.data$IDandDrug <- data$Gene
  if(!is.null(BED.data$Drug)){
    for(i in 1:dim(data)[1]){
      if(is.na(data$Drug[i])){
        BED.data$IDandDrug[i] <- data$Gene[i]
      }
    }
  }

  par(mar = c(plot.margin, plot.margin, plot.margin, plot.margin))
  circos.clear()
  circos.par(cell.padding = c(0, 0, 0, 0))
  # circos.initializeWithIdeogram(plotType = c("axis", "labels"))
  circos.initializeWithIdeogram(plotType = NULL)
  
  circos.genomicLabels(BED.data, labels.column = dim(BED.data)[2], side = "downward",
                       col = "black", line_col = "blue", cex = 0.5*font.scale) # genes and drugs
  
  circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
    chr = CELL_META$sector.index
    xlim = CELL_META$xlim
    ylim = CELL_META$ylim
    circos.rect(xlim[1], 0, xlim[2], 1, col = rand_color(1))
    circos.text(mean(xlim), mean(ylim), chr, cex = 0.4*font.scale, col = "white", facing = "inside", niceFacing = TRUE)
  }, track.height = 0.08, bg.border = NA)

  title(myTitle)
  BED.data.link = BED.data[BED.data$Type == "FUSION",]
  if(dim(BED.data.link)[1] != 0){ # no fusion
    for (i in 1:dim(BED.data.link)[1]){
      location = gsub(" ", "", BED.data.link$Location[i], fixed = TRUE)
      location = unlist(strsplit(location, "-"))
      chrom1 = unlist(strsplit(location[1], ":"))[1]
      pt1 = as.numeric(unlist(strsplit(location[1], ":")))[2]
      chrom2 = unlist(strsplit(location[2], ":"))[1]
      pt2 = as.numeric(unlist(strsplit(location[2], ":")))[2]
      circos.link(sector.index1=paste("chr", chrom1, sep=""), point1=pt1,
                  sector.index2=paste("chr", chrom2, sep=""), point2=pt2,
                  col = line.color, lwd = line.width)
      # R color: http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf
    }
  }
  circos.genomicTrack(BED.data, track.height = 0.05, bg.border = NA,
                      panel.fun = function(region, value, ...) {
                        cex = (value[[1]] - min(value[[1]]))/(max(value[[1]]) - min(value[[1]]))
                        i = getI(...)
                        for(i in 1:dim(value)[1]){
                          current_value = value[i,]
                          current_region = region[i,]
                          if(current_value$Type == "CNA" & current_value$Alteration == "AMP"){
                            circos.genomicPoints(current_region, value = current_value, cex = symbol.size, pch = 8, col="darkgreen", ...)
                          }
                          else if(current_value$Type == "CNA" & current_value$Alteration == "HOMDEL"){
                            circos.genomicPoints(current_region, value = current_value, cex = symbol.size, pch = 8, col="red", ...)
                          }
                          else if(current_value$Type == "Inframe"){
                            circos.genomicPoints(current_region, value = current_value, cex = symbol.size, pch = 16, col="darkgreen", ...)
                          }
                          else if(current_value$Type == "Missense"){
                            circos.genomicPoints(current_region, value = current_value, cex = symbol.size, pch = 16, col="black", ...)
                          }
                          else if(current_value$Type == "Truncation"){
                            circos.genomicPoints(current_region, value = value[i,], cex = symbol.size, pch = 16, col="red", ...)
                          }
                        }
                      })
  circos.genomicTrack(BED.data, track.height = 0.05, bg.border = NA,
                      panel.fun = function(region, value, ...) {
                        cex = (value[[1]] - min(value[[1]]))/(max(value[[1]]) - min(value[[1]]))
                        i = getI(...)
                        for(i in 1:dim(value)[1]){
                          current_value = value[i,]
                          current_region = region[i,]
                          if(current_value$Type == "EXP mRNA" & current_value$Alteration == "UP"){
                            circos.genomicPoints(current_region, value = current_value, cex = symbol.size, pch = 24, col="darkgreen", ...)
                          }
                          else if(current_value$Type == "EXP mRNA" & current_value$Alteration == "DOWN"){
                            circos.genomicPoints(current_region, value = current_value, cex = symbol.size, pch = 25, col="red", ...)
                          }
                        }
                      })
  circos.genomicTrack(BED.data, track.height = 0.05, bg.border = NA,
                      panel.fun = function(region, value, ...) {
                        cex = (value[[1]] - min(value[[1]]))/(max(value[[1]]) - min(value[[1]]))
                        i = getI(...)
                        for(i in 1:dim(value)[1]){
                          current_value = value[i,]
                          current_region = region[i,]
                          if(current_value$Type == "EXP Protein" & current_value$Alteration == "UP"){
                            circos.genomicPoints(current_region, value = current_value, cex = symbol.size, pch = 15, col="darkgreen", ...)
                          }
                          else if(current_value$Type == "EXP Protein" & current_value$Alteration == "DOWN"){
                            circos.genomicPoints(current_region, value = current_value, cex = symbol.size, pch = 14, col="red", ...)
                          }
                        }
                      })
  circos.clear()
}