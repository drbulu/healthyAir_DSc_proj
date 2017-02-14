# Helper functions to help processing of Traffic data

traffic_helpers_02 = list()

## Clean up a raw URL table

## List headline functions first! The main functions are listed first, 
# because they make it easier to work out what the helper function set is about
# and it also highlights the required depencencies, meaning that no cruft,
# i.e. unused functions, are transferred :)

# the functions are basically listed in the reverse order of function dev.
# developped sequentially. more specific functionality was create first,
# then more general functions next

##### Processing All Excel Files Specified by Metadata File #####

# this is the penultimate function

# metadata processing function
traffic_helpers_02$processFileMetadata = function(metaData, isList = F){
    processTimer <- proc.time() # time process
    cat(paste0("processFileMetadata() - Processing metadata file ", 
        deparse(substitute(metaData)), "...\n" ))
    processedEntries = 0
    resultSet = list()
    for(i in 1:nrow(metaData)){
        # extract and process data using metadata info
        dataID = paste0(metaData$Month[i], "_",metaData$Year[i])
        resultSet[[dataID]] = traffic_helpers_02$processTrafficTable(
            xlsFilePath = metaData$Local.XLS[i], 
            monthData = metaData$Month[i], 
            yearData = metaData$Year[i])
        processedEntries = i    
    }
    cat(paste0("processFileMetadata() - Processing complete! ", 
        processedEntries, " entries processed! \n"))
    # return 
    if(isList) return(resultSet)
    else return(Reduce(function(...) merge(..., all=T), resultSet))
}

##### Processing All Excel Sheets within a Single File #####

# for this to work smoothly, we need to take full advantage of
# the "mergedURLTable" metadata table to help us

traffic_helpers_02$processTrafficTable = function(xlsFilePath, monthData, yearData){
    # 0. diagnostic msg: to keep track of processing progress
    cat(paste("processTrafficTable() - Processing:", 
        paste(monthData, yearData), xlsFilePath, "\n"))
    # 1. Extract sheet names using readxl
    sheetNames = traffic_helpers_02$excel_sheets_quiet(xlsFilePath)
    # 2. Choose behaviour depending on the sheet names
    # i) check if the sheetName set contains Table 3 or Pages 4 to 6
    checkTable3 = grepl("[Tt]able( )*3", sheetNames)
    checkPageNames = grepl("[Pp]age( )*[4|5|6]", sheetNames)
    # ii) If the previewed file contains the names "Page 4-6"
    if(TRUE %in% checkPageNames){
        sheetNameSubset = unique(sheetNames[which(checkPageNames == TRUE)])
        sheetList = list()
        for( sheetID in sheetNameSubset){
            sheetSubset = traffic_helpers_02$read_excel_quiet(path = xlsFilePath, sheet = sheetID)
            sheetNum = as.numeric(
                gen_helpers_01$extractMatch(x = sheetID, pattern = "[0-9]+"))
            roadLevel = switch(as.character(sheetNum), 
                "4" = "Rural", 
                "5" = "Urban", 
                "6" = "All")
            sheetList[[sheetID]] = traffic_helpers_02$processSheet(
                x = sheetSubset, m=monthData, y=yearData, 
                roadType = roadLevel)
        }
        return(Reduce(function(...) merge(..., all=T), sheetList))
    }
    # iii) If the previewed file contains the name "Table 3"
    if(TRUE %in% checkTable3){
        sheetID = which( checkTable3 == TRUE )
        sheetSubset = traffic_helpers_02$read_excel_quiet(path = xlsFilePath, sheet = sheetID)
        sheetData = traffic_helpers_02$processSheet(
            x = traffic_helpers_02$preProcOldSheet(sheetSubset), 
            m=monthData, y=yearData, roadType = "Rural")
        return(sheetData)
    }
}

##### Processing Individual Excel Sheets #####

### ... Main Sheet Processing functions ...

### NOTE: Guiding principle... obtain only what you need!
## required data: = Region, State, Preliminary, Revised

traffic_helpers_02$processSheet = function(x, m, y, roadType){
    # 0. diagnostic msg: to keep track of processing progress
    cat(paste("processSheet() - Processing:", paste(m, y, roadType), "\n"))
    # 1: Label the datasheet according to the regions
    regionNames = c("Northeast", "South Atlantic", "North Central", 
        "South Gulf", "West")
    # Find the column containing the region (and state) info
    regionREGEX = paste(paste0("^", regionNames, "$"), collapse = "|")
    regionCol = c()
    for(i in 1:length(x)){
        isFound = grepl(regionREGEX, x[, i])
        if(TRUE %in% isFound) {
            regionCol = i
            break;
        }
    }
    # create metadata using regionNames and new regionCol info
    regionMeta = traffic_helpers_02$prepRegionInfo(x, regionNames, regionCol)
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
    stateCol = unlist( traffic_helpers_02$findEntityColByRow(x, regex = "New York") )
    names(x)[stateCol] = "State"
    # ii) Get the Preliminary data for Current Month
    currMonDataCol = unlist( traffic_helpers_02$findEntityColByRow(x, regex = "[Pp]relim") )
    names(x)[currMonDataCol] = "Curr.Mon.Prelim.Veh.mMiles"
    # iii) Get the Revised datafor PRevious Month
    prevMonDataCol = unlist( traffic_helpers_02$findEntityColByRow(x, regex = "[Rr]evised") )
    names(x)[prevMonDataCol] = "Prev.Mon.Revised.Veh.mMiles"
    # 4: subset data cols using data names
    requiredNames = c("Region", "State", "Road.Type", "Year", "Curr.Mon", 
        "Curr.Mon.Prelim.Veh.mMiles", "Prev.Mon.Revised.Veh.mMiles")
    x = x[, requiredNames]
    # systematically remove invalid data rows...
    x = x[is.finite(suppressWarnings(as.numeric(x$Curr.Mon.Prelim.Veh.mMiles))), ]
    x = x[x$Region %in% regionNames, ]
    x = x[!grepl("total", x$State, ignore.case = T), ]
    x = x[!is.na(x$State), ] # newly added
    # 7: check data: warning if nrow(x) is not right. 51 states expected, including DC!
    if (nrow(x) != 51) warning(paste0(nrow(x), " row found, 51 expected!"))
    # 8: return data!
    return(x)
}

## need this helper function to preprocess Excel sheets that of the 
    ## old format. Strategy: Merge the Region and State columns to prepare
    ## the data for proper downstream processing in processSheet()
traffic_helpers_02$preProcOldSheet = function(x){
        # 1. Prepare the Region col for merge
        regionCol = unlist( traffic_helpers_02$findEntityColByRow(
            x, regex = "Northeast|South Gulf") )
        names(x)[regionCol] = "Region"
        x$Region = gsub("^[0-9]+(.)+[0-9]+$", "", x$Region)
        x[is.na(x$Region), "Region"] = ""
        # 2. Prepare the State col for merge
        statesCol = unlist( traffic_helpers_02$findEntityColByRow(
            x, regex = "New York") )
        names(x)[statesCol] = "State"
        x[is.na(x$State), "State"] = ""
        # 3. Merge Region and State to form Region.State
        x$Region.State = paste0(x$Region, x$State)
        # 4. Preserve columns that contain the words "Preliminary" and "Revised"
        # so that this information will be preserved for processSheet() to
        # process the data.frame result correctly.
        regionNames = c("Northeast", "South Atlantic", "North Central", 
            "South Gulf", "West")
        metaData = traffic_helpers_02$prepRegionInfo(
            x, regionNames, grep("Region.State", names(x)))
        metaRows = c()
        metaSearchEnd = metaData$startRow[1] - 1
        metaREGEX = "[Pp]relim|[Rr]evise"
        for(i in 1:metaSearchEnd){
            if(TRUE %in% grepl(metaREGEX, x[i, ])) metaRows = append(metaRows, i)
        }
        x[metaRows, "Region.State"] = "metaData"
        x = x[x$Region.State != "", ]  #?
        # 4. Remove the original Region and State cols. Avoids later issues
        x = x[, !grepl("^Region$|^State$", names(x))]
        return(x)
}

##### Accessory Sheet Processing functions ####

# helper functionality to support processSheet()

# function to help move the region info to a new column: useful
traffic_helpers_02$prepRegionInfo = function(x, regionSet, regionCol = 1){
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

traffic_helpers_02$findEntityColByRow = function(x, regex){
    resList = list()
    for(i in 1:nrow(x)){
        isFound = grepl(regex, x[i,])
        if(TRUE %in% isFound) resList[[ paste0("row", i) ]] = which(isFound == T)
    }
    return(resList)
}

### ... silent readxl wrapper functions with the help of purrr

## Borrowed entirely from this code:
# https://github.com/tidyverse/readxl/issues/82
# From:  t-kalinowski (27-Aug-2016 )

traffic_helpers_02$excel_sheets_quiet <- function(path) {
    if(!require(readxl) | !require(purrr)) 
        stop("Package(s) 'readxl' and/or 'purrr' not found! ")
    quiet_excel_sheets <- purrr::quietly(readxl::excel_sheets)
    out <- quiet_excel_sheets(path)
    if(length(c(out[["warnings"]], out[["messages"]])) == 0)
        return(out[["result"]])
    else readxl::excel_sheets(path)
}

traffic_helpers_02$read_excel_quiet <-  function(...) {
    if(!require(readxl) | !require(purrr)) 
        stop("Package(s) 'readxl' and/or 'purrr' not found! ")
    quiet_read <- purrr::quietly(readxl::read_excel)
    out <- quiet_read(...)
    if(length(c(out[["warnings"]], out[["messages"]])) == 0)
        return(out[["result"]])
    else readxl::read_excel(...)
}