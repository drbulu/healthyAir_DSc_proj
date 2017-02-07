# Data Processing helpers 


## Need function to process an entire URL table

# 
# Functionality required:
#     
# 1) Obtain a single data table from HTML source code -->
# 2) Obtain a list of data tables from a single URL metadata table
# 3) Proces each list of data tables to create a single _data series_
# data series: a combination of a group and demographic subgroup.
# e.g. Adult (group) / Income (demographic subgroup)
# optional: save the list of tables to disc.
# 4) Combine as set of data series into a single master list.
# optional: get the tables form disc
# 5) Save the tables to disc

# and one or two check functions to see if the data processing is correct :)


##### Helper function 2 ##### 

## helper function list

asthma_helper_func_02 = list()

## 1. Using URL to extract the data table that it points to 

# Options: There are a number of options for webscraping. Two of these
# are XML (or XML2) or rvest (seems newer). After a brief look, I decided
# to go with RStudio's rvest package as they seem to make good stuff.
# However, I will forego the "tidyverse" syntax for now. Saving that for L8r.
# below are some potentially useful links:
#   https://www.r-bloggers.com/using-rvest-to-scrape-an-html-table/
#   http://stackoverflow.com/questions/28729507/scrape-multiple-linked-html-tables-in-r-and-rvest
#   https://cran.r-project.org/web/packages/rvest/ (docs)

# from brief inspection of source code for a couple of the tables
# a) Desired HTML element type: <table>
# b) table class: class="opt-in table table-bordered"

# Will start with a simple implementation of this function. If more complex
# input or result validation processing is required, this can be updated accordinly
# since html_table() returns a list, we will return only the table that is the
# first element of the list. This seems reasonable since each URL contains only ONE
# table. This will need to change should that assumption become void.
asthma_helper_func_02$getTableHTML = function(url) if (require(rvest)) return(html_table(read_html(url), header = NA, fill = T)[[1]])

## 2. Obtain list of data frames from URL metadata table

# Briefly tried using a lapply approach.. to no avail: http://stackoverflow.com/questions/17842705/

getDatasetTablesFromURL = function(urlTable){
    resultsList = list()
    for(i in 1:nrow(urlTable)){
        
        recencyID = toupper(substr(urlTable[i, "Recency"],1,1))
        
        dataTableID = paste0(urlTable[i, "Year"], ".", 
            recencyID, urlTable[i, "demID"], ".",
            urlTable[i, "Group"])
        
        resultsList[[dataTableID]] = asthma_helper_func_02$getTableHTML(urlTable$URL[i])
    }
    return(resultsList)
}

## 3. 

# reduce merge() http://stackoverflow.com/questions/8091303/
# Reduce(function(...) merge(..., all=T), list.of.data.frames)

# handy test function
getDataListSlice = function(dataList, subset = 1, merge=T){
    y = lapply(dataList, FUN = function(x) return(x[subset,]) )
    if (merge) return( Reduce(function(...) merge(..., all=T), y))
    else return (y)    
}

lifetimeTables = lapply(urlTables2, FUN = function(x) return(x[x$Recency == "lifetime", ])  )

# Checked a representative table (first one) from each list using the getDatalistSlice()
# function to try to ensure that the data sets were all in a predictable format

# for current
# a = getDataListSlice(urlTables2)
# testTable = getDatasetTablesFromURL(a)

# for lifetime
# lifetimeTables = lapply(urlTables2, FUN = function(x) return(x[x$Recency == "lifetime", ])  )
# lifetimeSummaryMeta = getDataListSlice(lifetimeTables)
# lifetimeTestTables = getDatasetTablesFromURL(lifetimeSummaryMeta)

# both sets of instructions returned a list of dataframes that contained ONE representative
# table for adult and child data for each demographic for current and lifetime data
# idea: this should be sufficient to see what data processing patterns will be required!

# ... results 

# Adult tables (current):
# testing showed that tables adult.C1 and C3, C5, C6, C7 are pretty much good in terms of initial colNames
# need minimal cleaning

# Tables C21, 
# Row 1 = table colnames
# need to fix colnames then merge with current colnames
# except col 1: state is fine, but duplicated

# child tables (current): col names are in Row 1
# need to sanitize and use to replace initial colNames



## 4. 



## 5. 

