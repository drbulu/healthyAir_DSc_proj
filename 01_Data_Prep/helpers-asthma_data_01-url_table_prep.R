# Helper functions to help processing of Asthma data

# implementing helper functions as a list of functions in order to 
# 1) reduce the Global namespace footprint
# 2) enable ease of functionality management: 
#    i.e. easier removal of groups of functions when not required :)
asthma_helper_func_01 = list()

## Metadata table generation 
asthma_helper_func_01$initAsthmaMetaData = function(){
    demographic = c("Overall", "Gender", "Age", 
        "Ethnicity", "Education", "Income")
    demID = c(1, 21, 3, 5, 6, 7)    
    hasChildData = c("Y", "Y", "Y", "Y", "N", "N")    
    asthmaMetaData = as.data.frame(cbind(demographic, demID, hasChildData), 
        stringsAsFactor = F)
    return(asthmaMetaData)
}

# Core function for producing URLs from Current data archive
asthma_helper_func_01$getCurrentAsthmaURL = function(yearID, baseURL, recID, demID, isAdult = TRUE){
    tableName = paste0("table", recID, demID, ".htm")
    # returns URL depending on whether ADULT or CHILD data is needed!
    if (isAdult) return( paste(baseURL, yearID, tableName, sep="/") )
    else return( paste(baseURL, yearID, "child", tableName, sep="/") )
}

# Core function for producing URLs from Archive data archive
asthma_helper_func_01$getArchiveAsthmaURL = function(yearID, baseURL, recID, demID, isAdult = TRUE){  
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

# Make a data frame to make data organisation more simple and useful :)
# This is MUCH better than getting a large number of lists and/or vectors
# also means that I can inject fewer variables into the equation :)
# This function gets the tables for ONE specific demographic (demID) for
# all of the years specified in yearSeries for the chosen subset (isAdultData)

asthma_helper_func_01$prepAsthmaYearURLsByID = function(demID, yearSeries, isAdultData = T){    
    ## empty data.frame object to fill later
    urlTable = data.frame()
    currentRow = 0
    ## URL component info
    baseURL = "https://www.cdc.gov/asthma/brfss"
    recencyStatus = c("current", "lifetime")
    ## work by recency
    for (recName in recencyStatus){
        recID = toupper(substr(recName, 1,1))
        ## work by YEAR            
        for (y in yearSeries){
            currentRow = nrow(urlTable) + 1    
            # Generate URL by year: select function for URL creation
            # based on year (y): 2011 = start of current data series.
            urlFunc = NULL            
            if (as.numeric(y) < 2011) urlFunc = asthma_helper_func_01$getArchiveAsthmaURL
            else urlFunc = asthma_helper_func_01$getCurrentAsthmaURL
            # prepare arguments list for do.call()
            urlArgs = list(yearID = y, baseURL = baseURL, recID = recID, 
                demID = demID, isAdult = isAdultData)
            # populate results table
            urlTable[currentRow, "Year"] = y
            urlTable[currentRow, "demID"] = demID
            urlTable[currentRow, "Recency"] = recName
            urlTable[currentRow, "URL"] = do.call(urlFunc, args=urlArgs)            
        }
    }    
    return(urlTable)
}

# Create a list of URL data tables based on input information: Designed to obtain
# both adult and child data from the default metadata table for ease of use by 
# abstraction of underlying details. User needs to call this function without
# arguments to get all the data. The "endYear" variable can be used to change the 
# recency of the data collected to restrict data series size or to include future data
# as required. Further refinements could be made, but it should suffice to keep this 
# function relatively simple to avoid unecessary complexity and resulting logical error.
# by default: earliest time period for adult and child tables are 2000 and 2005.
# previous years contain comparatively incomplete data. Save us some drama :)

# it might be good to modify this function to have a timeFrame variable instead of
# endYear to enable custom date ranges... will work on this later :)

asthma_helper_func_01$createAsthmaURLTables = function(metaData = NULL, groups = c("adult", "child"), endYear = 2014){
    # choose default dataset if none provided
    if (is.null(metaData)) metaData = asthma_helper_func_01$initAsthmaMetaData()
    # create list object for results, and commence table creation
    resultList = list()    
    for (i in 1:length(groups)){
        # choose input options depending on data group
        yearSeries = c()
        getAdultURL = c()        
        if (tolower(groups[i]) == "adult"){
            yearSeries = c(2000:endYear)
            getAdultURL = TRUE
        } else {
            yearSeries = c(2005:endYear)
            getAdultURL = FALSE
            metaData = metaData[ metaData$hasChildData == "Y", ]
        }
        # apply input options to URL table creation
        for (j in 1:nrow(metaData)){
            tableID = paste0(groups[i], ".", metaData$demographic[j])           
            urlTableData = asthma_helper_func_01$prepAsthmaYearURLsByID(metaData$demID[j], 
                yearSeries, getAdultURL)
            # store group information within table for ease of use
            urlTableData$Group = tolower(groups[i])
            # add urlTableData to resultList using tableID 
            resultList[[tableID]] = urlTableData
        }        
    }
    return(resultList)
}