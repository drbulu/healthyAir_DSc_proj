#### Traffic Monitoring data: Data Preparation 1 ####

## 00 - Load required helper functions
source("./01_Data_Prep/helpers/general_helpers_01.R")
source("./01_Data_Prep/helpers/helpers-traffic_data_prep.R")

## 01 - Extract metadata information form data source

# i) Create list of tables of URLs to access using data source
trafficMainPage = "https://www.fhwa.dot.gov/policyinformation/travel_monitoring/tvt.cfm"
rawTableList = gen_helpers_01$getHTMLtables(trafficMainPage)

# ii) Merge list of URL tables information into a single metadata file
# the last table (# 16) is not needed. Represents unusable dataset
mergedURLTable = traffic_helpers_01$checkAndMergeTableList(rawTableList[1:15])

## 02 - Cleanup the URL entry metadata in the merged table
mergedURLTable = traffic_helpers_01$cleanTrafficURLtable(mergedURLTable)

## 03 - Download excel files for further processing

# More useful to download the files before subsequent processing
# download files from processed table
rawDataDir = "./Data/traffic/raw"
traffic_helpers_01$downloadFilesFromTable(urlTable = mergedURLTable, 
    dataDir = rawDataDir, subsetREGEX = "XLS")

## 04 Examine Sheets in dataset to workout data extraction protocol/algo

rawFiles = paste(rawDataDir, grep("(.)+\\.xls(.){0,1}", dir(rawDataDir), value=T), sep="/")

extractSheetNames = function(x) if(require(xlsx)) return(names(getSheets(loadWorkbook(x))))

# return simple 1 row data frame summarising sheetnames
summariseSheetNames = function(filePath){
    dataResult = data.frame()

    fileName = gsub("(.){0,}/", "", filePath)
    dataResult[1, "FileName"] = fileName
    dataResult[1, "Year"] = gen_helpers_01$extractMatch(x = dataResult[1, "FileName"],
        pattern="[0-9]{2}", invertMatch=F)
    # get month regex using R constant: month.abb
    monthREGEX = paste(tolower(month.abb), collapse="|")
    monthID = gen_helpers_01$extractMatch(x = tolower(fileName),
        pattern=monthREGEX, invertMatch=F)
    if(!!length(monthID)) dataResult[1, "Month"] = monthID
    # summarise sheet
    dataResult[1, "Sheets"] = paste(extractSheetNames(filePath), collapse = "; ")
    return(dataResult)
}

summariseTableSheetInfo = function(fileList){
    # consolidate data frame list
    summarySheetTable = Reduce(function(...) merge(..., all=T), lapply(fileList, summariseSheetNames))
    # create factor variables for grouping
    summarySheetTable$Sheets = factor(summarySheetTable$Sheets)
    summarySheetTable$Month = factor(summarySheetTable$Month, levels = tolower(month.abb))
    summarySheetTable = summarySheetTable[order(summarySheetTable$Year, summarySheetTable$Month), ]
    # return summary table
    return(summarySheetTable)
}

getDataSubsetByLevel = function(dataFrame, groupCol, groupID = 1){
    targetGroup = levels(dataFrame[, groupCol])[groupID]
    dataSubset = dataFrame[ dataFrame[, groupCol] == targetGroup, ]
    return(dataSubset)
}

getSheetGroupSample = function(dataFrame, groupCol){
    # count groups
    groupCount = length(levels(dataFrame[, groupCol]))
    # subset all groups and get first and last entry
    groupList = lapply(1:groupCount, FUN = function(x){
        y = getDataSubsetByLevel(dataFrame, groupCol, groupID = x)
        y = y[c(1, length(y)), ]
        y$GroupID = x
        return(y)
    })
    # merge all subsets into group sample
    groupSample = Reduce(function(...) merge(..., all=T), groupList)
    return(groupSample)
}

getSheetGroupList = function(dataFrame, groupCol){

    groupCount = length(levels(dataFrame[, groupCol]))
    # subset all groups and get first and last entry
    groupList = lapply(1:groupCount, FUN = function(x){
        return(getDataSubsetByLevel(dataFrame, groupCol, groupID = x))
    })
    return(groupList)
}

# get data frame of sheetNames
# sorted by Month-Year and grouped by sheet names.
trafficSheetNames = summariseTableSheetInfo(rawFiles)

z = getSheetGroupSample(trafficSheetNames, "Sheets")
# extract the subsets belonging to each group
a = getSheetGroupList(trafficSheetNames, "Sheets")
# lapply(a, function(x) nrow(x))

# use grep to disect commonalities between groups

# Table 3
