# General helper functions that are generally useful

gen_helpers_01 = list()

## 6a. Helpful regular expression function

# lovely little function - uses REGEX to cut out matching text: 
# inspired by searching ?regmatches (help page) on RStudio console

gen_helpers_01$extractMatch = function(x, pattern, invertMatch=F){
    result = regmatches(x, regexpr(pattern, x), invert = invertMatch)
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