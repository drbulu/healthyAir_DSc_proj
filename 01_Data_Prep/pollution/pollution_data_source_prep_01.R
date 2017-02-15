#### Asthma Prevanence data: Data Preparation 1 ####

## 00 - Load required helper functions
source("./01_Data_Prep/helpers/general_helpers_01.R")

## 01 - Download Excel file from URL

# Prepare data directory
epaRawDataDir = "./Data/pollution/raw/"
gen_helpers_01$createTargetDir(epaRawDataDir)

# download file to data dir from URL
epaStatSummary = "https://www.epa.gov/sites/production/files/2016-12/state_tier1_90-16.xls"
epaSummaryDataPath = paste0(epaRawDataDir, gen_helpers_01$getURLFileName(epaStatSummary))
gen_helpers_01$downloadFileURL(targetURL = epaStatSummary, 
    destPath = epaSummaryDataPath, printMsg = T, delay = 0.25)

## 02 - Extract Data Sheet from Excel file

# Identify sheet names using: gen_helpers_01$excel_sheets_quiet(epaSummaryDataPath)
epaStateSummary = gen_helpers_01$read_excel_quiet(path = epaSummaryDataPath, 
    sheet = "state_trends", skip = 1)

## 03 - Prepare data for exploratory analysis

## Note: The data is pretty straight forward, the challenge is to
## make it available with minimum processing for exploratory analysis

# simplest solution, transform data into 2 forms:
# a) metadata: containing descriptions of data elements
# b) data: contains the relevant information in an appropriate format. i.e. Years are NOT 
# cool note: unique works on data.frame objects :)

## A - Create metadata file

# metadata cols: type, Entity, Desc 

epaCreateStateMetadata = function(epaData){
    # metadata construction blueprint
    metaTypeList = list(
        State = c("STATE_ABBR", "STATE_FIPS"),
        Source = c("tier1_code", "tier1_description"),
        Pollutant = c("pollutant_code") )
    metaDataNames = c("Type", "Entity", "Description")
    # process metadata
    metaDataList = list()
    for(i in names(metaTypeList)){
        # get basic metadata: unique combinations of components
        entryData = unique(epaData[, metaTypeList[[i]] ])
        if(i == "State") entryData$STATE_FIPS = paste0("FIPS_CODE=", 
            entryData$STATE_FIPS)
        if(i == "Pollutant"){
            entryData = data.frame(entryData, stringsAsFactors = F)
            entryData$Description = "unit=1000 tons"  
        } 
        names(entryData) = metaDataNames[2:3]
        entryData$Type = i
        metaDataList[[i]] = entryData[, metaDataNames]
    }
    return( Reduce( function(...) merge(..., all = T), metaDataList) )
}

## B - Process data file

epaTransposeStateData = function(epaData){
    # easier to have nested functions for niche functionality
    # a) convert headings from emissionsYY to Year (YYYY) format
    sub_help_prepYear = function(x){
        x = gsub("emissions", "", x)
        y = format(as.Date(paste0("01/01/", x), format = "%d/%m/%y" ), "%Y")
        return(y)
    }
    # b) transpose data: http://stackoverflow.com/questions/6645524/
    transposeDf = function(dataFrame){
        matrix = t(dataFrame[, 2:ncol(dataFrame)])
        colnames(matrix) <- dataFrame[, 1]
        return (as.data.frame(matrix, stringsAsFactors = F))
    }
    
    epaData$ItemCode = paste(epaData$STATE_ABBR, epaData$tier1_code, 
        epaData$pollutant_code, sep = ".")
    
    eData = epaData[, c("ItemCode", grep("emissions[0-9]+", names(epaData), value=T)) ]
    
    eData[nrow(eData)+1, ] = names(eData)
    # add Year metadata prior to data transposition
    eData[nrow(eData), 1] = "Year"
    eData[nrow(eData), 2:length(eData)] = sub_help_prepYear( eData[nrow(eData), 2:length(eData)] )
    # eData[2, length(eData)] = sub_help_prepYear( eData[2, length(eData)] )
    # transpose and return formatted data
    eData = transposeDf(eData)
    # nifty name reordering. Move Year from last to first col
    sortedNames = c("Year", grep("year", names(eData), 
        ignore.case = T, invert = T, value = T))
    row.names(eData) = NULL
    return(eData[, sortedNames])
}

#
x = epaCreateStateMetadata(epaStateSummary)
y = epaCreateStateData(epaStateSummary)


# you could stop here, or you could

# These functions below arequite useful, but when applied to the whole dataset, 
# they make the dataset too sparse!

epaExpandTimeSeriesByID = function(tsData){
    # prepare elements for processing
    dataCol = grep("year", names(tsData), ignore.case = T, invert = T)
    dataName = names(tsData)[dataCol]
    idElements = unlist(strsplit(dataName, split = "\\."))
    # restructure dataset
    tsData$State = idElements[1]
    tsData$Tier1_ID = idElements[2]
    tsData$Pollutant = idElements[3]
    names(tsData) = gsub(dataName, paste0(idElements[3], ".emissions"), names(tsData))
    cat("epaExpandTimeSeriesByID - Finished processing ", dataName, ".\n")
    # return data
    return(tsData)
}

epaReformatTimeSeriesData = function(epaData, byPollutant = T){
    # prepare data for analysis
    isYearColFound = TRUE %in% grepl("Year", names(epaData))
    if(!isYearColFound) epaData = epaTransposeStateData(epaData)
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