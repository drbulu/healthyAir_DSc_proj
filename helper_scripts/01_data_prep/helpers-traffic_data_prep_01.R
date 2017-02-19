# Helper functions to help processing of Traffic data

traffic_helpers_01 = list()

## Clean up a raw URL table

# Table names not suitable for merging
# lapply(tab, FUN = function(x) names(x)) # name check

traffic_helpers_01$fixTableStructure = function(inputTable){
    if ( TRUE %in% grepl("http", names(inputTable)) ){
        newRow = nrow(inputTable) + 1
        correctNames = c("Monthly Report", "PDF Version", "XLS Version")        
        for(i in 1:length(correctNames)) inputTable[newRow, i ] = names(inputTable)[i]
        names(inputTable) = correctNames
    }    
    return(inputTable)
}

## Merge table before further processing

# need to fix a couple of common URL pattern errors, induced 
# during web scraping somehow. Here seems a good place to fix it

traffic_helpers_01$checkAndMergeTableList = function(dataList){
    # fix table structure of affected tables    
    dataList = lapply(dataList, FUN = traffic_helpers_01$fixTableStructure)
    # fix table names of remaining tables
    dataList = lapply(dataList, FUN=function(x){
        names(x) = gsub("( )+", ".", names(x))
        return(x)
    })
    # merge and return combined data.frame from dataList tables
    outputData = Reduce(function(...) merge(..., all=T), dataList)
    # first URL cleanup
    clipREGEX = "(\\.){2,}/(\\.){2,}"
    fuseREGEX = "gov[0-9]{2}[a-zA-Z]+/"
    insertSegment = ".gov/policyinformation/travel_monitoring/"
    for(c in 1:length(outputData)) {
        outputData[, c] = gsub(clipREGEX, "", outputData[, c])
        
        for(r in 1:length( outputData[, c] )){
            targetURL = outputData[r, c]
            fuseTest = grepl(fuseREGEX, targetURL)
            if(fuseTest) outputData[r, c] = gsub("\\.gov", insertSegment, targetURL)
        }
    }
    return(outputData)
}

## Reformat merged table and clean before use

# obtain file data for convenience. Probably more efficient to do this here, 
# than when it comes time to process the URLs for download.
traffic_helpers_01$cleanTrafficURLtable = function(dataTable){    
    # prepare column 1 values for downstream processing
    dataTable[, 1] = gsub("\\| ", "", dataTable[, 1])
    # extract date information from column 1 to separate new variables (columns)
    urlPrefixREGEX = "^http(.)+/"
    trimREGEX = " \\|(.)+"
    for(i in 1:nrow(dataTable)){
        # get the second and third values of split (contain dates)
        dataMeta = unlist(strsplit(dataTable[i, 1], split=" "), recursive = F)
        dataTable[i, "Monthly.Report"] = dataMeta[1]
        dataTable[i, "Month"] = dataMeta[2]
        dataTable[i, "Year"] = dataMeta[3]
    }    
    # remove redundant info from data columns
    for(i in 1:3) dataTable[, i] = gsub(trimREGEX, "", dataTable[, i])
    
    for(i in 1:nrow(dataTable)){
        # extract filename: alternatively, URL can be split generally using:
        # x = strsplit(urlString, "/"). Filename would be the last segment length(x)
        dataTable[i, "PDF.File"] = gsub(urlPrefixREGEX, "", dataTable[i, "PDF.Version"])
        dataTable[i, "XLS.File"] = gsub(urlPrefixREGEX, "", dataTable[i, "XLS.Version"])
    }        
    
    # order table by combining Month and Year data to create a valid date
    # pasting in 1 makes the resulting Date valid (i.e. avoids NA)
    dataTable = dataTable[order(as.Date(
        paste(1, dataTable$Month, dataTable$Year), 
        format="%d %B %Y")), ]
    return(dataTable)
}

## Download file for further processing

traffic_helpers_01$downloadFilesFromTable = function(urlTable, dataDir, subsetREGEX = "XLS", method="libcurl", delay=0.5){
    # create the directory if not available
    if(!dir.exists(dataDir)) dir.create(dataDir, recursive = T)
    # select relevant data and identify relevant cols
    dataSubset = urlTable[, grepl(subsetREGEX, names(urlTable))]
    
    urlCol = grep("[Vv]ersion", names(dataSubset))
    fileCol = grep("[Ff]ile", names(dataSubset))
    manifestName = deparse(substitute(urlTable))
    
    for (i in 1:nrow(dataSubset)){
        # extract URL and Filename
        targetURL = dataSubset[i, urlCol]
        targetFile = dataSubset[i, fileCol]
        # create destination filepath
        destFilePath = paste(dataDir, targetFile, sep="/")
        if (!file.exists(destFilePath)){
            cat(paste("downloading:", targetURL, "to", destFilePath, "\n"))
            download.file(targetURL, destFilePath, method=method, quiet = T)
            Sys.sleep(delay)
        } else {
            cat(paste("file already exists:", destFilePath, "\n"))
        }
        if(i == nrow(dataSubset)) cat(paste("\n.... download of URLs in", 
            paste0("\"", manifestName, "\""),  "complete!", "\n"))
    }
}