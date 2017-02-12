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
summariseSheetNames = function(filePath, advancedTrim=F){
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
    # Sheet group processing logic from empirical analysis of initial groups
    if(advancedTrim){
        # rationalising information to limit extraneous groups 
        # i.e remove groups that are not real
        # based on initial analysis of group counts
        # i) remove trailing whitespaces
        dataResult[1, "Sheets"] = gsub("( )+$", "", dataResult[1, "Sheets"])
        # ii) more whitespace removal - bad whitespace placement
        dataResult[1, "Sheets"] = gsub(" ;", ";", dataResult[1, "Sheets"])
        # iii) Basic typos relating to the "spelling" of the page col
        dataResult[1, "Sheets"] = gsub("Page1", "Page 1", dataResult[1, "Sheets"])
        dataResult[1, "Sheets"] = gsub("page", "Page", dataResult[1, "Sheets"])
        # iv) other typos
        dataResult[1, "Sheets"] = gsub("; Sheet2", "", dataResult[1, "Sheets"])
        dataResult[1, "Sheets"] = gsub("; SAVMT [Dd]ata", "; SAVMT", dataResult[1, "Sheets"])
    }
    return(dataResult)
}

summariseTableSheetInfo = function(fileList, advancedTrim=F){
    # consolidate data frame list
    sheetNameList = lapply(fileList, summariseSheetNames, advancedTrim=advancedTrim)
    summarySheetTable = Reduce(function(...) merge(..., all=T), sheetNameList)
    # create factor variables for grouping
    summarySheetTable$Sheets = factor(summarySheetTable$Sheets)
    summarySheetTable$Month = factor(summarySheetTable$Month, levels = tolower(month.abb))
    summarySheetTable = summarySheetTable[order(summarySheetTable$Year, 
        summarySheetTable$Month), ]
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

# version 2
trafficSheetNames2 = summariseTableSheetInfo(rawFiles, advancedTrim = T)

z2 = getSheetGroupSample(trafficSheetNames2, "Sheets")
# extract the subsets belonging to each group
a2 = getSheetGroupList(trafficSheetNames2, "Sheets")
# lapply(a2, function(x) nrow(x))

# use grep to disect commonalities between groups
# basically the main groups are those that contai

# unique(grep("[Pp]age", trafficSheetNames$Sheets, value=T))

# There are three main meta groups of the 16:
# i) Tables and NO Pages --> Table 3 = sheet of interest
# ii) Pages and No Tables --> Page 4, 5 and 6 = sheets of interest
#     Page 4: Table 3 - "Rural" - "Region and State"
#     Page 5: Table 3 - "Urban" - "Region and State"
#     Page 6: Table 3 - "ALL" - "Region and State"
# seems like Row 5 "State heading" or row 8 (data start)
# or row 7 (First subheading: safer) are good points to skip to
# Row 1 = Table title ... then skip to first
# Region heading
# Examples of differences: 10nov (1 line heading) vs 06apr (2 line heading)
# import first 10
# 1) Read title
# 2) Locate first region heading
# 3) 

# test your processing rules on the FIRST member of each group BEFORE
# trying things out on the rest of the data!

# possible solution ...
# Function to process a single xlsx file into a list of tables
# that may be combinable.

# for this to work smoothly, we need to take full advantage of
# the "mergedURLTable" metadata table to help us
mergedURLTable

processTrafficTable = function(xlsFilePath, monthData, yearData){
    # 1. Load required packages
    if(!require(xlsx) | !require(readxl)) stop("package not found!")
    # 2. Extract sheet names using xlsx
    sheetNames = names(getSheets(loadWorkbook(x)))
    # 3. Choose behaviour depending on the sheet names
    # i) check if the sheetName set contains Table 3 or Pages 4 to 6
    checkTable3 = grepl("[Tt]able 3", sheetNames)
    checkPageNames = grepl("[Pp]age [4|5|6]", sheetNames)
    # ii) s
    # if(TRUE %in% checkPageNames){ #body }
        # read in the list of sheets
        # loop through sheets and process them
    # if(TRUE %in% checkTable3){ #body }
        # read in the list of sheets
        # loop through sheets and process them
    
    sheetSubset = read_excel(path, sheet = 1, col_names = TRUE, na = "", skip = 0)
    
    #return?
}

# try: then refine based on mistakes made :)

# function to help move the region info to a new column: useful
prepRegionInfo = function(x, regionSet, regionCol = 1){
    # blank results table
    regionTable = data.frame()
    # search for region names in data
    searchRegions = c(regionSet, "TOTALS")
    regionIndices = grep(paste(paste0("^", searchRegions, "$"), collapse="|"), 
        x[, regionCol])
    # add region info to results table and return output
    for(i in 1:length(regionSet)) regionTable[i, "Name"] = regionSet[i]
    regionTable[, "startRow"] = regionIndices[1:length(regionSet)]
    for(i in 2:length(regionIndices)) regionTable[i-1, "endRow"] = regionIndices[i] - 1
    return(regionTable)
}

### NOTE: Guiding principle... obtain only what you need!
## required data: = Region, State, Preliminary, Revised

processSheet = function(x, m, y, roadType){
    
    # 1: Label the datasheet according to the regions
    regionNames = c("Northeast", "South Atlantic", "North Central", 
        "South Gulf", "West")
    regionMeta = prepRegionInfo(x, regionNames, 1)
    for(i in 1:nrow(regionMeta)){
        selectedRegion = regionMeta$Name[i]
        selectedRows = c(regionMeta$startRow[i]: regionMeta$endRow[i])
        x[selectedRows, "Region"] = selectedRegion   
    }
    # 2: Add year, month and location data
    x$Curr.Mon = m
    x$Year = y
    x$Road.Type = roadType
    
    # 3: Rename desired table cols tables using information
    # i) Label State col using "New York" (any consistent name will do!)
    stateCol = unlist( findEntityColByRow(x, regex = "New York") )
    names(x)[stateCol] = "State"
    # ii) Get the Preliminary data for Current Month
    currMonDataCol = unlist( findEntityColByRow(x, regex = "[Pp]relim") )
    names(x)[currMonDataCol] = "Curr.Mon.Prelim.Veh.mMiles"
    # iii) Get the Revised datafor PRevious Month
    prevMonDataCol = unlist( findEntityColByRow(x, regex = "[Rr]evised") )
    names(x)[prevMonDataCol] = "Prev.Mon.Revised.Veh.mMiles"
    # 4: subset data cols using data names
    requiredNames = c("Region", "State", "Road.Type", "Year", "Curr.Mon", 
        "Curr.Mon.Prelim.Veh.mMiles", "Prev.Mon.Revised.Veh.mMiles")
    x = x[, requiredNames]
    # 5: subset data rows using regionMeta metadata file
    lastRow = testMeta[nrow(testMeta), "endRow" ]
    if (lastRow > nrow(x) ) lastRow = nrow(x)
    x = x[1:lastRow, ]
    
    # remove vehicle miles rows that are non-numeric and remove "totals" rows!
    # suppressed warnings: NA coesion of non-numbers expected in invalid rows
    
    # need a new selection to prevent error!
    # cut by region first, then by total
    # x = x[is.finite(suppressWarnings(as.numeric(x$Curr.Mon.Prelim.Veh.mMiles))), ]
    x = x[x$Region %in% regionNames, ]
    x = x[!grepl("total", x$State, ignore.case = T), ]
    # 7: check data
    # warning if nrow(x) is below a specif threshold = 51 is good, 
    # 51 states expected, including DC!
    # 8: return data!
    return(x)
}

findEntityColByRow = function(x, regex){
    resList = list()
    for(i in 1:nrow(x)){
        isFound = grepl(regex, x[i,])
        if(TRUE %in% isFound) resList[[ paste0("row", i) ]] = which(isFound == T)
    }
    return(resList)
}

## Files to test
may15 = read_excel(rawFiles[147], sheet = "Page 4", col_names = TRUE, na = "", skip = 0)
jun07 = read_excel(rawFiles[49], sheet = "Page 4", col_names = TRUE, na = "", skip = 0)
nov02 = read_excel(rawFiles[1], sheet = "Table 3", col_names = TRUE, na = "", skip = 0)

## data processing function test

jun07_rural = processSheet(x = jun07, m="Nov", y="2007", roadType = "rural")
may15_rural = processSheet(x = may15, m="Nov", y="20015", roadType = "rural")

# Table 3
