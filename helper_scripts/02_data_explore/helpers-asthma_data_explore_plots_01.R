data_exp_asthma_01 = list()

# gridExtra: https://github.com/baptiste/gridextra/wiki
data_exp_asthma_01$asthaPlotExploreGroup = function(combinedData){
    require(ggplot2)
    require(gridExtra)
    # create a data subset consisting only of the "Totals"
    dataSubset = combinedData[which(grepl("Total", combinedData$State)), ]
    dataSubset$Prev.perc = as.numeric(dataSubset$Prev.perc)
    dataSubset$Prev.perc.SE = as.numeric(dataSubset$Prev.perc.SE)
    dataSubset$Year = as.numeric(dataSubset$Year)
    # extract the recency data into a new Variable
    dataSubset$Recency = gsub("[0-9]+", "", dataSubset$Table.ID)
    dataSubset$Recency = gsub("C", "Current", dataSubset$Recency)
    dataSubset$Recency = gsub("L", "Lifetime", dataSubset$Recency)
    
    demography = unique(dataSubset$Demographic)
    groups = unique(dataSubset$Group.ID)
    
    dataList = list()
    # Basic strategy:
    # iterate: Demographics and Groups. 
    # facet by Dem.Category, Colour and Shape by Recency
    for(d in demography){
        targetDemographic = grepl(d, dataSubset$Demographic)
        for(g in groups){
            targetGroup = grepl(g, dataSubset$Group.ID)
            dataSlice = dataSubset[targetDemographic & targetGroup, ] 
            if(nrow(dataSlice) > 0){
                dataPlot = data_exp_asthma_01$plotAsthmaGroupData(inputData = dataSlice)
                dataList[[tolower(paste0(g, "_", d))]] = dataPlot   
            }
        }
    }
    return(dataList)
}

data_exp_asthma_01$plotAsthmaGroupData = function(inputData){

    myTheme = theme(
        text = element_text(size = 10),
        axis.text.x = element_text(angle = 90),
        legend.key.size = unit(10, "points"),
        legend.text = element_text(size = 8) ) 
    
    plotRecency = function(dataSource, recency, prefix){
        suffix = paste(unique(dataSource$Group.ID), "by",  unique(dataSource$Demographic) )
        titleText = tolower(paste0(recency, ": ", suffix))
        recency = match.arg(arg = recency, choices = c("Current", "Lifetime"))
        recPlot = ggplot(data=dataSource[ dataSource$Recency == recency, ]) + 
            aes(y=Prev.perc, x=as.character(Year), fill=Dem.Category) + 
            geom_bar(position = "stack", stat = "identity") + 
            labs(x = "", y = "Prevalence %", title = titleText) + 
            myTheme
        return(recPlot)
    }
    
    currentPlot = plotRecency(dataSource = inputData, recency = "Current")
    lifetimePlot = plotRecency(dataSource = inputData, recency = "Lifetime")
    
    comboPlot = arrangeGrob(grobs=list(currentPlot, lifetimePlot), ncol=2)
    
    return(comboPlot)
}
