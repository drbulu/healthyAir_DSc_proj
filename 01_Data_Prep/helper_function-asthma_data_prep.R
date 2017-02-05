
# Core function for producing URLs from Current data archive
getCurrentAsthmaURL = function(yearID, baseURL, recID, demID, isAdult = TRUE){
    tableName = paste0("table", recID, demID, ".htm")
    # returns URL depending on whether ADULT or CHILD data is needed!
    if (isAdult) return( paste(baseURL, yearID, tableName, sep="/") )
    else return( paste(baseURL, yearID, "child", tableName, sep="/") )
}

# Core function for producing URLs from Archive data archive
getArchiveAsthmaURL = function(yearID, baseURL, recID, demID, isAdult = TRUE){  
    # preprocess yearID correctly if year is/not 2010.
    if (as.character(yearID) != "2010") yearID = substr(yearID, 3,4)    
    # extract recName according to recID (statement works ONLY for single item vector!)
    recName = ifelse(toupper(recID) == "L", "lifetime", "current")
    # as per getCurrentAsthmaURL() with recName modification
    tableName = paste0("table", recID, demID, ".htm")
    # returns URL depending on whether ADULT or CHILD data is needed!
    if (isAdult) return( paste(baseURL, yearID, recName, tableName, sep="/") )    
    else return( paste(baseURL, yearID, "child", recName, tableName, sep="/") )
}

## temp: test of do call concept
foo = function(x, isAvg){
    
#     funcList = c(mean, sd)
#     func = NULL    
#     if (isAvg) func = mean
#     else func = sd

    # this line is cleaner than the commented out lines
    # for binary choice between single element vectors :)
    func = ifelse(isAvg, mean, sd)
        
    result = do.call(func, args=list(x))
    return(result)
}

# Make a data frame to make data organisation more simple and useful :)
# This is MUCH better than getting a large number of lists and/or vectors
# also means that I can inject fewer variables into the equation :)

# function specific to processing URLs from the current dataset: 2011 - 2014


prepAsthmaYearURLs = function(metaData, yearEntry, dataSubset = c("adult", "child")){
    # empty data.frame object to fill later
    urlTable = data.frame()
    currentRow = 0
    # input validation: to help prevent redundancy
    dataSubset = unique(dataSubset)
    
    baseURL = "https://www.cdc.gov/asthma/brfss"
    
    
    
    
    for (d in dataSubset){
        selectAdult = ifelse(tolower(d) == "adult", TRUE, FALSE)
        for (i in 1:nrow(metaData)){
            currentRow = currentRow + 1    
            
        }
        
    }
    
    
}

prepAsthmaURLs = function(metaData, yearSet){

    
    yearID = NULL
    demID = ""
    
    urlList = list()
    
    for (year in yearSet){
        yearID = year
        
        for (r in 1:nrow(metaData)) {
            demID = metaData[r, "id"]
            
        }
        
    }
    
    return(urlList)
}

