library(plyr)
library(doBy)
library(ggplot2)
library(reshape2)
library(stringr)
library(xtable)
library(tableHTML)


generatePlotFlex <- function(plotData,f,lab,output){
  plot<-ggplot(plotData, aes(x = as.numeric(m), y = f))  +
    theme_bw() +
    geom_line(aes(linetype=factor(features)),stat = "identity") +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x),
      labels = scales::trans_format("log10", scales::math_format(10^.x))
    ) +
    geom_point(mapping=aes(x=as.numeric(m), y=f, shape=factor(features)), size=3)+
    scale_linetype_discrete(guide=FALSE)+
    scale_shape_discrete()+
    xlab("Value of m") + 
    ylab(lab) +
    labs(shape = "Number of features")+
    theme(legend.position="bottom",legend.text=element_text(size=15)) +
    scale_x_continuous(breaks=c(1,2,4,6,10)) + theme(aspect.ratio=0.45)+
    annotation_logticks(sides = "l") +
    theme(text = element_text(size=13),axis.text.x = element_text(angle=60, hjust=1))+guides(shape=guide_legend(nrow=1,byrow=TRUE))

  ggsave(output,  width = 12)
  
}
  
generatePlotEvol <- function(plotData,f,lab,output){
  plot<-ggplot(plotData, aes(x = as.numeric(features), y = f))  +
    theme_bw() +
    geom_line() +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x),
      labels = scales::trans_format("log10", scales::math_format(10^.x))
    ) +
    geom_point(mapping=aes(x=as.numeric(features), y=f), size=3)+
    scale_linetype_discrete(guide=FALSE)+
    scale_shape_discrete()+
    xlab("Features") + 
    ylab(lab) +
    theme(legend.position="bottom",legend.text=element_text(size=15)) +
    #theme(aspect.ratio=0.45)+
    annotation_logticks(sides = "l") +
    theme(text = element_text(size=13),axis.text.x = element_text(angle=60, hjust=1))+guides(shape=guide_legend(nrow=1,byrow=TRUE))
  
  ggsave(output,  width = 12)
  
}


generatePlotComp <- function(plotData,f,lab,output){
  plot<-ggplot(plotData, aes(x = factor(features), y = f, group=m))  +
    theme_bw() +
    geom_line(aes(linetype=factor(m))) +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x),
      labels = scales::trans_format("log10", scales::math_format(10^.x))
    ) +
    geom_point(mapping=aes(x=factor(features), y=f, shape=m), size=3)+
    scale_linetype_discrete(guide=FALSE)+
    scale_shape_discrete(labels = c("Flexdiag(m=1)", "Evolutionary"))+
    labs( x = "Features", y = lab, shape = "Search\n") +
    theme(legend.position="bottom",legend.text=element_text(size=15)) +
    #theme(aspect.ratio=0.45)+
    #scale_x_continuous(breaks=c(50,100,500,1000,2000,5000)) +
    annotation_logticks(sides = "l") +
    theme(text = element_text(size=13),axis.text.x = element_text(angle=60, hjust=1))+
    guides(shape=guide_legend(nrow=1,byrow=TRUE))
  
  ggsave(output,  width = 12)
  
}

generatePlotReal <- function(plotData,f,lab,output){
  plot<-ggplot(plotData, aes(x = factor(features), y = f, group=m))  +
    theme_bw() +
    geom_line(aes(linetype=factor(m),color=factor(m))) +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x),
      labels = scales::trans_format("log10", scales::math_format(10^.x))
    ) +
    geom_point(mapping=aes(x=factor(features), y=f, shape=factor(m)), size=3)+
    scale_linetype_discrete(guide=FALSE)+
    xlab("Features") + 
    ylab(lab) +
    theme(legend.position="bottom",legend.text=element_text(size=15)) +
    #theme(aspect.ratio=0.45)+
    #scale_x_continuous(breaks=c(50,100,500,1000,2000,5000)) +
    annotation_logticks(sides = "l") +
    theme(text = element_text(size=13),axis.text.x = element_text(angle=60, hjust=1))+
    guides(shape=guide_legend(nrow=1,byrow=TRUE))
  
  ggsave(output,  width = 12)
  
}

generatePlotDebianReal <- function(plotData,f,lab,output){
  plot<-ggplot(plotData, aes(x = factor(m), y = f, group=m))  +
    theme_bw() +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x),
      labels = scales::trans_format("log10", scales::math_format(10^.x))
    ) +
    geom_bar(stat="identity")+
    xlab("m value") + 
    ylab(lab) +
    theme(legend.position="bottom",legend.text=element_text(size=15)) +
    #theme(aspect.ratio=0.45)+
    annotation_logticks(sides = "l") +
    theme(text = element_text(size=13),axis.text.x = element_text(angle=60, hjust=1))+
    guides(shape=guide_legend(nrow=1,byrow=TRUE))
  
  ggsave(output,  width = 12)
  
}

minSizeCalculation <- function(x){
  subset <- dataFlexAutoSummary[ which(data$model==x$model ), ] 
  
  ##force to use fmdiag m=1 for minimal diagnossis avoiding non-complete results from evolutionary
  #si tenemos ejecutado con m=1 lo uso, si no el minimo y listo
  if(nrow(subset[ which(subset$m==1), ])>0){
    subset <- subset[ which(subset$m==1), ]
  }
  result <-  min(subset$resultSize)
  return(result)
}

######## Read data  
dataFlexGen = read.csv("./processedData/flex-gen.csv", header = TRUE,sep='|')
dataEvol = read.csv("./processedData/evol.csv", header = TRUE,sep='|')
dataFlexReal = read.csv("./processedData/flex-real.csv", header = TRUE,sep='|')
dataFlexAutoSummary = read.csv("./processedData/automotive.csv", header = TRUE,sep='|')

#dataFlexTiny = read.csv("./processedData/tiny.csv", header = TRUE,sep='|')
##remove bad data 5000 missing m=1
dataFlexGen <- subset(dataFlexGen, select = -c(productDesc) )
dataFlexReal <- subset(dataFlexReal, select = -c(productDesc) )

dataFlexGen<-dataFlexGen[which(!dataFlexGen$features==5000),]
dataEvol<-dataEvol[which(!dataEvol$features==5000),]


######## Flexdiag Tiny model individual.
#dataFlexTinySummary <- summaryBy(dependencies+product+resultSize+minSize+time + minimality + accuracy~ features + m, data = dataFlexTiny, FUN = function(x) { c(mean = mean(x)) } )

## Latex table.
#print(xtable(dataFlexTinySummary), include.rownames=FALSE, file="./output/flex-tiny-table.tex")
#write_tableHTML(tableHTML(dataFlexTinySummary, rownames = FALSE, caption = 'FlexDiag with Tiny Models'), "./output/flex-tiny-table.html", complete_html = FALSE)

######## Flexdiag Automotive model individual.
dataFlexAutoSummary <- summaryBy(time + minimality + accuracy~ model + m + variables+relations, data = dataFlexAutoSummary, FUN = function(x) { c(mean = mean(x)) } )

## Latex table.
print(xtable(dataFlexAutoSummary), include.rownames=FALSE, file="./output/flex-auto-table.tex")
write_tableHTML(tableHTML(dataFlexAutoSummary, rownames = FALSE, caption = 'FlexDiag with Automotive Models'), "./output/flex-auto-table.html", complete_html = FALSE)



######## Flexdiag Random model individual.
dataFlexGenSummary <- summaryBy(dependencies+resultSize+minSize+time + minimality + accuracy~ features + m, data = dataFlexGen, FUN = function(x) { c(mean = mean(x)) } )
## Plots.
generatePlotFlex(dataFlexGenSummary,dataFlexGenSummary$time.mean,"Time in milliseconds (log scale)","./output/flex-gen-time.pdf")
generatePlotFlex(dataFlexGenSummary,dataFlexGenSummary$minimality.mean,"Minimality (log scale)","./output/flex-gen-minimality.pdf")
generatePlotFlex(dataFlexGenSummary,dataFlexGenSummary$accuracy.mean,"Accuracy (log scale)","./output/flex-gen-accuracy.pdf")

## Latex table.
print(xtable(dataFlexGenSummary), include.rownames=FALSE, file="./output/flex-gen-table.tex")
#htmlTable(dataFlexGenSummary)
write_tableHTML(tableHTML(dataFlexGenSummary, rownames = FALSE, caption = 'FlexDiag with Random Models'), "./output/flex-gen-table.html", complete_html = FALSE)
#temp<-dataFlexRealTotalSummary[which(startsWith(as.character(dataFlexRealTotalSummary$model),'R')),]

#print(xtable(temp), include.rownames=FALSE, file="./output/temp.tex")


######## Evolutionary 
dataEvolSummary <- summaryBy(dependencies+resultSize+minSize+time + minimality + accuracy~ features + m, data = dataEvol, FUN = function(x) { c(mean = mean(x)) } )

generatePlotEvol(dataEvolSummary,dataEvolSummary$time.mean,"Time in milliseconds (log scale)","./output/evol-time.pdf")
generatePlotEvol(dataEvolSummary,dataEvolSummary$minimality.mean,"Minimality (log scale)","./output/evol-minimality.pdf")
generatePlotEvol(dataEvolSummary,dataEvolSummary$accuracy.mean,"Accuracy (log scale)","./output/evol-accuracy.pdf")

## Latex table.
print(xtable(dataEvolSummary), include.rownames=FALSE, file="./output/evol-table.tex")
write_tableHTML(tableHTML(dataEvolSummary, rownames = FALSE, caption = 'Evolutionary results'), "./output/evol-table.html", complete_html = FALSE)

######## Flexdiag vs Evolutionary 
##merge the data
dataFlexGen[which(dataFlexGen$m ==1),]
filteredData<-dataFlexGen[which(dataFlexGen$m ==1),]
filteredData$m<-as.factor(filteredData$m)
mergedData <- rbind(dataEvol,filteredData)

##prepare summary
mergedDataSummary <- summaryBy(dependencies+resultSize+minSize+time + minimality + accuracy~ features + m, data = mergedData, FUN = function(x) { c(mean = mean(x)) } )

generatePlotComp(mergedDataSummary,mergedDataSummary$time.mean,"Time in milliseconds (log scale)","./output/flex-vs-evol-time.pdf")
generatePlotComp(mergedDataSummary,mergedDataSummary$minimality.mean,"Minimality (log scale)","./output/flex-vs-evol-minimality.pdf")
generatePlotComp(mergedDataSummary,mergedDataSummary$accuracy.mean,"Accuracy (log scale)","./output/flex-vs-evol-accuracy.pdf")

## Latex table.
print(xtable(mergedDataSummary), include.rownames=FALSE, file="./output/flex-vs-evol-table.tex")
write_tableHTML(tableHTML(mergedDataSummary, rownames = FALSE, caption = 'Evolutionary vs Flexdiag'), "./output/flex-vs-evol-table.html", complete_html = FALSE)

######## Realistic
## Full data.

dataFlexRealTotalSummary <- summaryBy(dependencies+resultSize+minSize+time + minimality + accuracy~ features + m + model, data = dataFlexReal, FUN = function(x) { c(mean = mean(x)) } )
generatePlotReal(dataFlexRealTotalSummary,dataFlexRealTotalSummary$time.mean,"Time in milliseconds (log scale)","./output/flex-real-time.pdf")
generatePlotReal(dataFlexRealTotalSummary,dataFlexRealTotalSummary$minimality.mean,"Minimality (log scale)","./output/flex-real-minimality.pdf")
generatePlotReal(dataFlexRealTotalSummary,dataFlexRealTotalSummary$accuracy.mean,"Accuracy (log scale)","./output/flex-real-accuracy.pdf")

#dataFlexRealTotalSummary<-arrange(dataFlexRealTotalSummary, model, m)
#dataFlexRealTotalSummary<-dataFlexRealTotalSummary[which(startsWith(as.character(dataFlexRealTotalSummary$model),"REAL")),]
## Latex table.
print(xtable(dataFlexRealTotalSummary), include.rownames=FALSE, file="./output/flex-real-table.tex")
write_tableHTML(tableHTML(dataFlexRealTotalSummary, rownames = FALSE, caption = 'Flexdiag with real models'), "./output/flex-real-table.html", complete_html = FALSE)

## Only Debian data.
dataFlexRealDebianSummary<- summaryBy(dependencies+resultSize+minSize+time + minimality + accuracy~ features + m + model, data = dataFlexReal[which(dataFlexReal$model =="xenial.xml"),], FUN = function(x) { c(mean = mean(x)) } )
generatePlotDebianReal(dataFlexRealDebianSummary,dataFlexRealDebianSummary$time.mean,"Time in milliseconds (log scale)","./output/flex-real-debian-time.pdf")
generatePlotDebianReal(dataFlexRealDebianSummary,dataFlexRealDebianSummary$minimality.mean,"Minimality (log scale)","./output/flex-real-debian-minimality.pdf")
generatePlotDebianReal(dataFlexRealDebianSummary,dataFlexRealDebianSummary$accuracy.mean,"Accuracy (log scale)","./output/flex-real-debian-accuracy.pdf")
## Latex table.
print(xtable(dataFlexRealDebianSummary), include.rownames=FALSE, file="./output/flex-real-debian-table.tex")
write_tableHTML(tableHTML(dataFlexRealDebianSummary, rownames = FALSE, caption = 'Flexdiag with Debian models'), "./output/flex-real-debian-table.html", complete_html = FALSE)

## Without Debian data.
dataFlexRealNoDebianSummary<- summaryBy(dependencies+resultSize+minSize+time + minimality + accuracy~ features + m + model, data = dataFlexReal[which(!dataFlexReal$model =="xenial.xml"),], FUN = function(x) { c(mean = mean(x)) } )
generatePlotReal(dataFlexRealNoDebianSummary,dataFlexRealNoDebianSummary$time.mean,"Time in milliseconds (log scale)","./output/flex-real-no-debian-time.pdf")
generatePlotReal(dataFlexRealNoDebianSummary,dataFlexRealNoDebianSummary$minimality.mean,"Minimality (log scale)","./output/flex-real-no-debian-minimality.pdf")
generatePlotReal(dataFlexRealNoDebianSummary,dataFlexRealNoDebianSummary$accuracy.mean,"Accuracy (log scale)","./output/flex-real-no-debian-accuracy.pdf")
## Latex table.
print(xtable(dataFlexRealNoDebianSummary), include.rownames=FALSE, file="./output/flex-real-no-debian-table.tex")
write_tableHTML(tableHTML(dataFlexRealNoDebianSummary, rownames = FALSE, caption = 'Flexdiag with Splot models'), "./output/flex-real-no-debian-table.html", complete_html = FALSE)
