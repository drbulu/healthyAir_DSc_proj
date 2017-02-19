
epa_help_explore_01 = list()

# These functions Expand the variables in the transposed data summary created
# during the data preparation phase of the EPA State summary dataset.
# These functiosn are NOT intended to process the ENTIRE dataset, but to prepare
# subsets of interest for exploratory analysis and other analyses. Basically,
# the functions, particularly:
#   epa_help_explore_01epaReformatTimeSeriesData()
# were slow when applied to the roughly 5200 variables in the transposed data set.
# Further, the datasets tended to be sparse due to missing values, presumably
# because (among other reasons) some pollutants were not emmitted by certain sources.

# you could stop here, or you could

# These functions below arequite useful, but when applied to the whole dataset, 
# they make the dataset too sparse!

epa_help_explore_01$epaExpandTimeSeriesByID = function(epaDataSubset){
    # prepare elements for processing
    dataCol = grep("year", names(epaDataSubset), ignore.case = T, invert = T)
    dataName = names(epaDataSubset)[dataCol]
    idElements = unlist(strsplit(dataName, split = "\\."))
    # restructure dataset
    epaDataSubset$State = idElements[1]
    epaDataSubset$Tier1_ID = idElements[2]
    epaDataSubset$Pollutant = idElements[3]
    names(epaDataSubset) = gsub(dataName, paste0(idElements[3], ".emissions"), names(epaDataSubset))
    cat("epaExpandTimeSeriesByID - Finished processing ", dataName, ".\n")
    # return data
    return(epaDataSubset)
}

## The funciton below expands the reach of the previous function and basically
## enables the preparation of datasets consisting of multiple columns of interest.

epa_help_explore_01$epaReformatTimeSeriesData = function(epaData, byPollutant = T){
    # prepare data for analysis
    isYearColFound = TRUE %in% grepl("Year", names(epaData))
    if(!isYearColFound) epaData = epa_help_explore_01$epaTransposeStateData(epaData)
    # expand the contents of each individual time series
    dataList = lapply(grep("Year", names(epaData), invert=T, value=T), 
        FUN = function(x){ 
            dataSubset = epaData[, c("Year", x)]
            return( epaExpandTimeSeriesByID(dataSubset) ) 
        })
    # merge dataset according to "byPollutant" selection
    commonNames = c("Year", "State", "Tier1_ID")    
    if(byPollutant){
        # Note: dataList is NOT named... see above.
        dataList = lapply(1:length(dataList), FUN = function(x){
            pollutantCol = grep("[Pp]ollut", names(dataList[[x]]))
            return(dataList[[x]][, -pollutantCol])
        })        
        # return( Reduce( function(...) merge(..., by = commonNames), dataList) )
        return( Reduce( function(...) merge(..., all = T), dataList) )
    } else {
        # Note: dataList is NOT named... see above.
        dataList = lapply(1:length(dataList), FUN = function(x){
            names(dataList[[x]]) = gsub("(.)+emissions", "emissions", names(dataList[[x]]))
            return(dataList[[x]])
        })
        return( Reduce( function(...) merge(..., all = T), dataList) )
    }
}