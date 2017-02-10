#### Traffic Monitoring data: Data Preparation 1 ####

## 01 - Create list of tables of URLs to access

trafficMainPage = "https://www.fhwa.dot.gov/policyinformation/travel_monitoring/tvt.cfm"

# i) import helper functions
# source("./01_Data_Prep/helpers-asthma_data_01-url_table_prep.R")

# http://stackoverflow.com/questions/31924546/rvest-table-scraping-including-links

getHTMLtables = function(url){
    if (!require(XML) | !require(httr) ) stop('required packages "XML" or "httr" not present')
    
    doc <- content(GET(url))
    getHrefs <- function(node, encoding) {  
        x <- xmlChildren(node)$a 
        if (!is.null(x)) paste0("http://", parseURI(url)$server, xmlGetAttr(x, "href"), " | ", xmlValue(x) ) else xmlValue(xmlChildren(node)$text) 
    }
    tab <- readHTMLTable(doc,  elFun = getHrefs, stringsAsFactors = F)
}

rawTableList = getHTMLtables(trafficMainPage)

## 02 - Clean up the URL table

# Table names not suitable for merging
# lapply(tab, FUN = function(x) names(x)) # name check

fixTableStructure = function(inputTable){
    if ( TRUE %in% grepl("http", names(inputTable)) ){
        newRow = nrow(inputTable) + 1
        correctNames = c("Monthly Report", "PDF Version", "XLS Version")        
        for(i in 1:length(correctNames)) inputTable[newRow, i ] = names(inputTable)[i]
        names(inputTable) = correctNames
        names(inputTable) = gsub("( )+", ".", names(inputTable))
    }    
    return(inputTable)
}

checkAndMergeTableList = function(dataList){
    
    checkedNames = lapply(dataList, FUN=function(x){
        
    })
    
}

# the last table (# 16) is not needed. Historical archive
cleanTableList = lapply(rawTableList[1:15], FUN = fixTableStructure)


## 03 - Merge table before further processing


# freaks out if table col names are illegal e.g. have spaces
# mergedURLTable = Reduce(function(...) merge(..., all=T), rawTableList[1:15])

