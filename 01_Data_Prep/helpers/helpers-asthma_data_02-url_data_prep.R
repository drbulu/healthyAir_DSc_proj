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

asthma_helpers_02 = list()

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
asthma_helpers_02$getTableHTML = function(url) if (require(rvest)) return(html_table(read_html(url), header = NA, fill = T)[[1]])

## 2. Obtain list of data frames from URL metadata table

# Briefly tried using a lapply approach.. to no avail: http://stackoverflow.com/questions/17842705/

asthma_helpers_02$getDatasetTablesFromURL = function(urlTable){
    resultsList = list()
    for(i in 1:nrow(urlTable)){
        
        recencyID = toupper(substr(urlTable[i, "Recency"],1,1))
        
        dataTableID = paste0(urlTable[i, "Year"], ".", 
            recencyID, urlTable[i, "demID"], ".",
            urlTable[i, "Group"])
        
        resultsList[[dataTableID]] = asthma_helpers_02$getTableHTML(urlTable$URL[i])
    }
    return(resultsList)
}

## 3. Preprocess the names of specific tables to avoid downstream data merge issues

# These are Adult L21 tables from 2001 and 2002

asthma_helpers_02$preprocAdultGenderL21 = function(inputDataList){
    tableIndexREGEX = "200[1-2].L21.adult"
    indexSelect = grepl(tableIndexREGEX, names(inputDataList))
    inputDataList[indexSelect] = lapply(inputDataList[indexSelect],
        FUN = function(x){
            sizeCols = grep("^[Ss]ample[Ss]ize", names(x))
            if(length(sizeCols) == 2){
                names(x)[ sizeCols[1] ] = paste0("Male.", names(x)[ sizeCols[1] ])
                names(x)[ sizeCols[2] ] = paste0("Female.", names(x)[ sizeCols[2] ])
            }
            prevCols = grep("^[Pp]revalence", names(x))
            if(length(prevCols) == 2){
                names(x)[ prevCols[1] ] = paste0("Male.", names(x)[ prevCols[1] ])
                names(x)[ prevCols[2] ] = paste0("Female.", names(x)[ prevCols[2] ])                
            }
            return(x)
        })    
    return(inputDataList)
}

## 4. process table names

## 4a. Reformat the names of columns (variables) that span two rows:
# header row and first data row
asthma_helpers_02$mergeMultiRowColNames = function(targetTable){
    newNames = paste(names(targetTable), targetTable[1, ], sep=".")
    newNames = gsub("^X[0-9]+\\.", "", newNames)
    newNames = gsub("\\.State", "", newNames)    
    return(newNames)
}

## 4b. Clean preprocessed (and merged if required) namees prior to data merge
asthma_helpers_02$cleanTableColNames = function(rawTableNames, isGenderPercent=T){
    # remove spaces
    processedNames = gsub("(\\s)+", "", rawTableNames)
    # commence processing
    processedNames = gsub("95(.)+CI(.)+", ".95_CI", processedNames)
    processedNames = gsub("Prevalence(.)+[Pp]ercent(.)+", "Prev.perc", processedNames)
    processedNames = gsub("Prevalence(.)+[Nn]umber(.)+", "Prev.num", processedNames)
    processedNames = gsub("StandardError", "Prev.perc.SE", processedNames)
    # Fix SE.(percent) to just SE
    processedNames = gsub("(.)[Pp]ercent(.)", "", processedNames)
    processedNames = gsub("[Rr]ace(.)+[Ee]thnicity", "Ethnicity", processedNames)
    # to correctly process names based on input table type
    if(isGenderPercent){
        processedNames = gsub("FemalePrevalence", "Female.Prev.perc", processedNames)
        processedNames = gsub("MalePrevalence", "Male.Prev.perc", processedNames)        
    } else {
        processedNames = gsub("FemalePrevalence", "Female.Prev", processedNames)
        processedNames = gsub("MalePrevalence", "Male.Prev", processedNames)        
    }
    # required to complete processing of Prevalence columns
    processedNames = gsub("FemalePrev", "Female.Prev", processedNames)
    processedNames = gsub("MalePrev", "Male.Prev", processedNames)
    # final tidy up
    processedNames = gsub("^Female.S", "FemaleS", processedNames)
    processedNames = gsub("^Male.S", "MaleS", processedNames)    
    processedNames = gsub("^(\\.)+", "", processedNames)
    # return data frame names
    return(processedNames)
}

## 5. Clean the names and columns of a particular table

## used by createDataseriesFromList() to merge a set of related tables 

asthma_helpers_02$cleanAsthmaTableNames = function(targetTable, removeNameRow = T, isGenderPercent=T){
    # merge table names if required
    if(tolower(targetTable[1,1]) == "state" ){
        names(targetTable) = asthma_helpers_02$mergeMultiRowColNames(targetTable)
        if(removeNameRow) targetTable = targetTable[-1, ]
    }
    # tidy table names
    names(targetTable) = asthma_helpers_02$cleanTableColNames(
        names(targetTable), 
        isGenderPercent)
    # remove spurious columns from latest adult tables (2011 - 2014)
    if("||||||" %in% names(targetTable)){        
        colsToKeep = !grepl("(\\|){2,}", names(targetTable))
        targetTable = targetTable[, colsToKeep]
    }
    return(targetTable)
}
 
## 6. Consolidate all of the individual tables in a particular dataseries

## 6a. Obtain generally useful and helpful regular expression function
source("./01_Data_Prep/helpers/general_helpers_01.R")

## 6b. Consolidation function

# a data series is a list of tables that consist of the same data observations
# collected over successive years.

# Aim: create a single data frame that neatly contains all of this information
# My preferred solution to this problem: http://stackoverflow.com/questions/8091303/
# Reduce(function(...) merge(..., all=T), list.of.data.frames)
# Arguably one of my favourite tools in my R toolkit

asthma_helpers_02$createDataseriesFromList = function(sourceTableList, sortData = T){
    # clean the names of the data.frames in sourceTableList
    sourceTableList = lapply(sourceTableList, 
        FUN = asthma_helpers_02$cleanAsthmaTableNames)
    # can add table name cleaning step here
    for(i in 1:length(sourceTableList)){
        tableID = names(sourceTableList)[[i]]
        sourceTableList[[i]][, "Group.ID"] = gen_helpers_01$extractMatch(tolower(tableID), "adult|child")
        sourceTableList[[i]][, "Year"] = gen_helpers_01$extractMatch(tableID, "[0-9]{4}")
        sourceTableList[[i]][, "Table.ID"] = gen_helpers_01$extractMatch(tableID, "[C|L][0-9]+")
    }    
    # need to get rid of the 95% CI columns: Neither needed nor unique!
    sourceTableList = lapply(sourceTableList, FUN = function(x){
        colsToKeep = !grepl("95_CI", names(x))
        return(x[, colsToKeep])
    })
    # Seamlessly condense dataframe list: http://stackoverflow.com/questions/8091303/
    mergedTable = Reduce(function(...) merge(..., all=T), sourceTableList)
    # For conveience: order table by Table.ID, then by State, then by Year    
    if(sortData) mergedTable = mergedTable[order(
        mergedTable$Table.ID, 
        mergedTable$State, 
        mergedTable$Year), ]
    return(mergedTable)
}

