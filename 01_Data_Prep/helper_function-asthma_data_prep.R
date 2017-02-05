# Helper functions to help processing of Asthma data

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

# Make a data frame to make data organisation more simple and useful :)
# This is MUCH better than getting a large number of lists and/or vectors
# also means that I can inject fewer variables into the equation :)
# This function gets the tables for ONE specific demographic (demID) for
# all of the years specified in yearSeries for the chosen subset (isAdultData)

prepAsthmaYearURLsByID = function(demID, yearSeries, isAdultData = T){    
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
            if (as.numeric(y) < 2011) urlFunc = getArchiveAsthmaURL
            else urlFunc = getCurrentAsthmaURL
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

# now to convert the data frame constructed by prepAsthmaYearURLsByID()
# to create a list of data frames

# from brief inspection of source code for a couple of the tables
# Desired HTML element type: <table>
# table class: class="opt-in table table-bordered"

# options: 
# XML: http://stackoverflow.com/questions/1395528/scraping-html-tables-into-r-data-frames-using-the-xml-package#1401367
# rvest: https://www.r-bloggers.com/using-rvest-to-scrape-an-html-table/
# useful: http://stackoverflow.com/questions/28729507/scrape-multiple-linked-html-tables-in-r-and-rvest
# rvest seems to be the way forward (more modern and flexible?)
# Docs: https://cran.r-project.org/web/packages/rvest/
# https://blog.rstudio.org/2015/09/24/rvest-0-3-0/
# will try non-"tidyverse" oldschool syntax first :)


library("rvest")
url <- "http://en.wikipedia.org/wiki/List_of_U.S._states_and_territories_by_population"
population <- url %>%
    html() %>%
    html_nodes(xpath='//*[@id="mw-content-text"]/table[1]') %>%
    html_table()


# how to get table
getTableHTML = function(url) if (require(rvest)) return(html_table(read_html(url), header = NA, fill = T))

# need to extract target table in getTableHTML() to make lapply() manageable.
b = lapply( y[,4], getTableHTML)
