# General helper functions that are generally useful

gen_helpers_01 = list()

## 6a. Helpful regular expression function

# lovely little function - uses REGEX to cut out matching text: 
# inspired by searching ?regmatches (help page) on RStudio console
# returns character(0) if no match found... not great.
gen_helpers_01$extractMatch = function(x, pattern, invertMatch=F){
    result = regmatches(x, regexpr(pattern, x), invert = invertMatch)
    result = ifelse(!length(result), NA, result)
    return(result)
}

# http://stackoverflow.com/questions/31924546/rvest-table-scraping-including-links

gen_helpers_01$getHTMLtables = function(url){
    if (!require(XML) | !require(httr) ) stop('required packages "XML" or "httr" not present')
    
    doc <- content(GET(url))
    getHrefs <- function(node, encoding) {  
        x <- xmlChildren(node)$a 
        if (!is.null(x)) paste0("http://", parseURI(url)$server, xmlGetAttr(x, "href"), " | ", xmlValue(x) ) else xmlValue(xmlChildren(node)$text) 
    }
    tab <- readHTMLTable(doc,  elFun = getHrefs, stringsAsFactors = F)
}

gen_helpers_01$createTargetDir = function(d) if(!dir.exists(d)) dir.create(d, recursive = T)

gen_helpers_01$getURLFileName = function(targetUrl) return(gsub("^http(.)+/", "", targetUrl))

gen_helpers_01$downloadFileURL = function(targetURL, destPath, printMsg = T, 
    delay = 0.25, method="libcurl"){
    if (!file.exists(destPath)){
        if(printMsg) cat(paste("downloading:", targetURL, "\nto:", destPath, "\n"))
        download.file(targetURL, destPath, method=method, quiet = T)
        if(printMsg) cat(paste("download of URL:\n", 
            paste0("\"", targetURL, "\""),  "complete!", "\n"))
        Sys.sleep(delay)
    } else {
        cat(paste("file already exists:", destPath, "\n"))
    }
}

### ... silent readxl wrapper functions with the help of purrr

## Borrowed entirely from this code:
# https://github.com/tidyverse/readxl/issues/82
# From:  t-kalinowski (27-Aug-2016 )

gen_helpers_01$excel_sheets_quiet <- function(path) {
    if(!require(readxl) | !require(purrr)) 
        stop("Package(s) 'readxl' and/or 'purrr' not found! ")
    quiet_excel_sheets <- purrr::quietly(readxl::excel_sheets)
    out <- quiet_excel_sheets(path)
    if(length(c(out[["warnings"]], out[["messages"]])) == 0)
        return(out[["result"]])
    else readxl::excel_sheets(path)
}

gen_helpers_01$read_excel_quiet <-  function(...) {
    if(!require(readxl) | !require(purrr)) 
        stop("Package(s) 'readxl' and/or 'purrr' not found! ")
    quiet_read <- purrr::quietly(readxl::read_excel)
    out <- quiet_read(...)
    if(length(c(out[["warnings"]], out[["messages"]])) == 0)
        return(out[["result"]])
    else readxl::read_excel(...)
}

# readr msg output was similarly annoying. Previous strategy didn't work
# fortunately, the answer was pretty simple :)
# The link was general but helpful: http://stackoverflow.com/a/41285354
gen_helpers_01$read_csv_quiet <-  function(...) {
    if(!require(readr)) stop("Package 'readr' not found! ")
    suppressWarnings(suppressMessages(
        readr::read_csv(...)
    ))
}

# basic function to save CSV with basic standardised functionality
gen_helpers_01$saveAsCsv = function(dataFrame, dirName, fileName){
    # create dataDir with any subdirs    
    if (!dir.exists(dirName)) dir.create(dirName, recursive = T)
    # create platform independent path
    filePath = file.path(dirName, fileName)
    write.csv( x = dataFrame, file = filePath, row.names = F)
}

# note: the file name pattern is "group_demographic.csv" e.g "adult_age.csv"
# note: readr seems to be able to read directly from zipped files without unzip()
gen_helpers_01$getCsvDataListFromDir = function(dirName){
    require(readr)
    dataList = list()
    dataFiles = grep("(*)+\\.csv$", dir(dirName), value = T)
    for(fileName in dataFiles){
        filePrefix = gsub("\\.csv$", "", fileName)
        dataList[[filePrefix]] = gen_helpers_01$read_csv_quiet(
            file = file.path(dirName, fileName))
    }
    return(dataList)
}