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