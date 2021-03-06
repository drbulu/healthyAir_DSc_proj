#### Asthma Prevanence data: Data Preparation - Testing data  ####

##### WARNING: THIS SCRIPT IS MESSY! It is a "virtual" scrap book #####

## 01 - Create list of tables of URLs to access

# i) import helper functions
source("./01_Data_Prep/helpers/helpers-asthma_data_01-url_table_prep.R")

# ii) create metadata tables of required URLS
asthma_URL_table_list = asthma_helper_func_01$createAsthmaURLTables()

# iii) remove list of helpers when no longer required
rm(asthma_helper_func_01)

## 02 - Obtain the data relating to the contents of the URL tables in step 01

source("./01_Data_Prep/helpers/helpers-asthma_data_02-url_data_prep.R")


# for current
currentTableURLs = getDataListSlice(asthma_URL_table_list)
currentTestTables = getDatasetTablesFromURL(currentTableURLs)

# for lifetime
lifetimeTableURLs = lapply(asthma_URL_table_list, FUN = function(x) return(x[x$Recency == "lifetime", ])  )
lifetimeSummaryMeta = getDataListSlice(lifetimeTableURLs)
lifetimeTestTables = getDatasetTablesFromURL(lifetimeSummaryMeta)

# for latest data series
latestTableURLs = lapply(asthma_URL_table_list, FUN = function(x) return(x[as.character(x$Year) == "2014", ])  )
latestSummaryMeta = getDataListSlice(latestTableURLs)
latestTestTables = getDatasetTablesFromURL(latestSummaryMeta)
## Data processing
lifetimeProcessed = list()

# works for all adult lifetime tables except Gender!
cleanBasicNames = function(targetTable, isGenderPercent=T){
    # remove spaces
    names(targetTable) = gsub("(\\s)+", "", names(targetTable))
    
    names(targetTable) = gsub("95(.)+CI(.)+", ".95_CI", names(targetTable))
    names(targetTable) = gsub("Prevalence(.)+[Pp]ercent(.)+", "Prev.perc", names(targetTable))
    names(targetTable) = gsub("Prevalence(.)+[Nn]umber(.)+", "Prev.num", names(targetTable))
    names(targetTable) = gsub("StandardError", "Prev.perc.SE", names(targetTable))
    names(targetTable) = gsub("[Rr]ace(.)+[Ee]thnicity", "Ethnicity", names(targetTable))
    if(isGenderPercent){
        names(targetTable) = gsub("FemalePrevalence", "Female.Prev.perc", names(targetTable))
        names(targetTable) = gsub("MalePrevalence", "Male.Prev.perc", names(targetTable))        
    } else {
        names(targetTable) = gsub("FemalePrevalence", "Female.Prev", names(targetTable))
        names(targetTable) = gsub("MalePrevalence", "Male.Prev", names(targetTable))        
    }
    names(targetTable) = gsub("^Female.S", "FemaleS", names(targetTable))
    names(targetTable) = gsub("^Male.S", "MaleS", names(targetTable))    
    names(targetTable) = gsub("^(\\.)+", "", names(targetTable))
    return(targetTable)
}

# works on Age data
mergeTableNameRows = function(targetTable, removeNameRow = T){
    newNames = paste(names(targetTable), targetTable[1, ], sep=".")
    newNames = gsub("^X[0-9]+\\.", "", newNames)
    newNames = gsub("\\.State", "", newNames)    
    names(targetTable) = newNames
    if(removeNameRow) return(targetTable[-1, ])
    return(targetTable)
}

# combine table name cleaning steps
cleanAsthmaTableNames = function(targetTable, removeNameRow = T, isGenderPercent=T){
    if(tolower(targetTable[1,1]) == "state" ){
        targetTable = mergeTableNameRows(targetTable, removeNameRow)
    }
    targetTable = cleanBasicNames(targetTable, isGenderPercent)    
    # get rid of spurios table in adult tables of 
    # latest data series (2011 - 2014)
    if("||||||" %in% names(targetTable)){        
        colsToKeep = !grepl("(\\|){2,}", names(targetTable))
        targetTable = targetTable[, colsToKeep]
    }
    return(targetTable)
}
    
# so far, cleaning works for archive data... :)

## check characteristics of table lists
lapply(latestTestTables, FUN = function(x) dim(cleanAsthmaTableNames(x)))
lapply(latestTestTables, FUN = function(x) head(cleanAsthmaTableNames(x)))

## Testing merging with single group

# a) extract table list
adultOverallTablesList = getDatasetTablesFromURL(asthma_URL_table_list$adult.Overall)
# b) process table names - more useful to move table name processing to the function below :)
# cleanAdultOverallTablesList = lapply(adultOverallTablesList, FUN = cleanAsthmaTableNames)
# c) merge preppped tables - new function required

# lovely little function - uses REGEX to cut out matching text: 
# inspired by searching ?regmatches (help page) on RStudio console

extractMatch = function(x, pattern, invertMatch=F){
    result = regmatches(x, regexpr(pattern, x), invert = invertMatch)
    return(result)
}

# Function to clean the names of a list of related tables: 
# e.g. the same data set collected over different years
# if 95% CI data is needed in merged data, there needs
# to be a way of preprocessing the names to make them
# unique. Not presently worth the time. No use case defined!

createDataseriesFromList = function(sourceTableList, sortData = T){
    # clean the names of the data.frames in sourceTableList
    sourceTableList = lapply(sourceTableList, FUN = cleanAsthmaTableNames)
    # can add table name cleaning step here
    for(i in 1:length(sourceTableList)){
        tableID = names(sourceTableList)[[i]]
        sourceTableList[[i]][, "Group.ID"] = extractMatch(tolower(tableID), "adult|child")
        sourceTableList[[i]][, "Year"] = extractMatch(tableID, "[0-9]{4}")
        sourceTableList[[i]][, "Table.ID"] = extractMatch(tableID, "[C|L][0-9]+")
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

# tested it using the Adult data series
adultOverallTablesList = getDatasetTablesFromURL(asthma_URL_table_list$adult.Overall)
adultOverallDataSeries = createDataseriesFromList(adultOverallTablesList)

## basically, the two essential elements are
# 1. getDatasetTablesFromURL(asthma_URL_metadata_table)
# 2. createDataseriesFromList(asthma_URL_metadata_table_list)

## this needs to be extended to:
## get lists of data FROM lists of metadata
# 1. a = lapply(asthma_URL_metadata_table_list, FUN=getDatasetTablesFromURL)
# 2. b = lapply(a, FUN=createDataseriesFromList)

# deceptively simple function, summarising all of the above functionality
# this pretty much completes the functionality. The next thing is to create
# checks for data processing to date, to improve its integrity before
# embarking on exploratory analysis!
createDataseriesList = function(asthmaURLTableList){
    dataTableList = lapply(asthmaURLTableList, FUN=getDatasetTablesFromURL)
    return(lapply(dataTableList, FUN=createDataseriesFromList))
}

# complete test, to start picking up possible errors
asthmaDataSeriesList = createDataseriesList(asthma_URL_table_list)

# more data check functions


checkTableListDim = function(dataFrameList){
    resultList = lapply(dataFrameList, FUN = function(x){
        y = dim(x)
        return(data.frame(row=y[1], col=y[2]))
    })
    return(resultList)
}

testDim = checkTableListDim(asthmaDataSeriesList)

# NOTE: used the testing to tweak the regex
# child - ethnicity (fixed regex)
# adult - ethnic group (fixed: same issue as child)
# adult - Gender: redundancy in multiple columns ...

adultGenderDataList = getDatasetTablesFromURL(asthma_URL_table_list$adult.Gender)

checkTableListNames = function(dataFrameList) return(lapply(dataFrameList, FUN = names))
adultGenderListNames = checkTableListNames(adultGenderDataList)

## We need to look at the adultGenderListNames to see what patterns we
## can find in the adultGenderDataList set of tables to work out how to fix
## the errors that we saw previously in data merge.

## Then we need to test how well our changes work through a combination of
# cleanBasicNames() and mergeTableNameRows().
# Problem: mergeTableNameRows() returns a data frame, so we should separate
# the name scrubbing functionality of mergeTableNameRows from the data
# whose columns are being named
# the process, as specified in cleanAsthmaTableNames() above is
# 1) ID multiple row table names and merge them
# 2) run the cleanBasicNames() to complete the process...

mergeMultiRowColNames = function(targetTable){
    newNames = paste(names(targetTable), targetTable[1, ], sep=".")
    newNames = gsub("^X[0-9]+\\.", "", newNames)
    newNames = gsub("\\.State", "", newNames)    
    return(newNames)
}

# copied cleanBasicNames() functionality here also...
# need this function to return cleaned names, not data.frame :)
cleanTableColNames = function(rawTableNames, isGenderPercent=T){
    # remove spaces
    processedNames = gsub("(\\s)+", "", rawTableNames)
    
    processedNames = gsub("95(.)+CI(.)+", ".95_CI", processedNames)
    processedNames = gsub("Prevalence(.)+[Pp]ercent(.)+", "Prev.perc", processedNames)
    processedNames = gsub("Prevalence(.)+[Nn]umber(.)+", "Prev.num", processedNames)
    processedNames = gsub("StandardError", "Prev.perc.SE", processedNames)
    # Fix SE.(percent) to just SE
    processedNames = gsub("(.)[Pp]ercent(.)", "", processedNames)
    processedNames = gsub("[Rr]ace(.)+[Ee]thnicity", "Ethnicity", processedNames)
    if(isGenderPercent){
        processedNames = gsub("FemalePrevalence", "Female.Prev.perc", processedNames)
        processedNames = gsub("MalePrevalence", "Male.Prev.perc", processedNames)        
    } else {
        processedNames = gsub("FemalePrevalence", "Female.Prev", processedNames)
        processedNames = gsub("MalePrevalence", "Male.Prev", processedNames)        
    }
    processedNames = gsub("^Female.S", "FemaleS", processedNames)
    processedNames = gsub("^Male.S", "MaleS", processedNames)    
    processedNames = gsub("^(\\.)+", "", processedNames)
    #
    
    return(processedNames)
}

processTableColNames = function(inputNames,  isGenderPercent=T){
    scrubbedNames = mergeMultiRowColNames(inputNames)
    scrubbedNames = cleanTableColNames(scrubbedNames, isGenderPercent=isGenderPercent)
    return(scrubbedNames)
}

# Now to test the functionality on the adultGenderListNames test list that contains
# all of the names of the adult Gender tables that need proper processing

test1_adultGenderListNames = lapply(adultGenderListNames, FUN=cleanTableColNames)
# check the unique list of names to see if all are homogeneous
unique(unlist(test1_adultGenderListNames))

# comparing it to the last set of names
setdiff(unique(unlist(test1_adultGenderListNames)), 
    test1_adultGenderListNames$`2014.L21.adult`)

# The names: "Male", "Female", "SampleSize" and "Prev.perc" stand out as needing to 
# be fixed. 
# 1. "Male", "Female" are there because the year 2000 datasets were not properly merged
# This is fixed by processTableColNames(). For example...
processTableColNames(adultGenderDataList$`2000.C21.adult`)
# 2. "SampleSize" and "Prev.perc" are due to issues processing the 2001 and 2002 datasets.
# seems to be now fixed by cleanTableColNames() for C21 tables. For example...
cleanTableColNames(names(adultGenderDataList$`2001.C21.adult`))
# problems persist with L21 tables though

# this should hopefully fix the situation
preprocAdultGenderL21 = function(inputDataList){
    tableIndexREGEX = "200[1-2].L21.adult"
    indexSelect = grepl(tableIndexREGEX, names(inputDataList))
    inputDataList[indexSelect] = lapply(inputDataList[indexSelect],
        FUN = function(x){
            sizeCols = grep("^[Ss]ample[Ss]ize", names(x))
            if(length(sizeCols) == 2){
                names(x)[ sizeCols[1] ] = paste0("Male", names(x)[ sizeCols[1] ])
                names(x)[ sizeCols[2] ] = paste0("Female", names(x)[ sizeCols[2] ])
            }
            prevCols = grep("^[Pp]revalence", names(x))
            if(length(prevCols) == 2){
                names(x)[ prevCols[1] ] = paste0("Male", names(x)[ prevCols[1] ])
                names(x)[ prevCols[2] ] = paste0("Female", names(x)[ prevCols[2] ])                
            }
            return(x)
        })    
    return(inputDataList)
}

# now we can hopefully fix this final issue with modifications to processTableColNames()
# that was previously defined above

processTableColNames = function(inputNames,  isGenderPercent=T){
    preppedpreprocAdultGenderL21(inputDataList)
    scrubbedNames = mergeMultiRowColNames(inputNames)
    scrubbedNames = 
    return(scrubbedNames)
}

# list to test with = adultGenderDataList

### NEW VERSION ... FINAL FORM FOR USE
# Note: this deprecates processTableColNames by using the functionality that it
# contains
cleanAsthmaTableNames = function(targetTable, removeNameRow = T, isGenderPercent=T){
    # merge table names if required
    if(tolower(targetTable[1,1]) == "state" ){
        names(targetTable) = mergeMultiRowColNames(targetTable)
        if(removeNameRow) targetTable = targetTable[-1, ]
    }
    # tidy table names
    names(targetTable) = cleanTableColNames(targetTable, isGenderPercent)
    # remove spurious columns from latest adult tables (2011 - 2014)
    if("||||||" %in% names(targetTable)){        
        colsToKeep = !grepl("(\\|){2,}", names(targetTable))
        targetTable = targetTable[, colsToKeep]
    }
    return(targetTable)
}

## Hopefully the final test
# cleanAsthmaTableNames()

# Now we can work on File I/O a bit ... need to be able to 
# 1. save a list of data.frames to a folder
# 2. retrieve the data frames from a list of files or a folder into a list
