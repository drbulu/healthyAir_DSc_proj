#### Asthma Prevanence data: Data Preparation - Testing data  ####

## 01 - Create list of tables of URLs to access

# i) import helper functions
source("./01_Data_Prep/helpers-asthma_data_01-url_table_prep.R")

# ii) create metadata tables of required URLS
asthma_URL_table_list = asthma_helper_func_01$createAsthmaURLTables()

# iii) remove list of helpers when no longer required
rm(asthma_helper_func_01)

## 02 - Obtain the data relating to the contents of the URL tables in step 01

source("./01_Data_Prep/helpers-asthma_data_02-url_data_prep.R")


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
    names(targetTable) = gsub("RaceandEthnicity", "Ethnicity", names(targetTable))
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

# Function to clean the names of a list of related tables: 
# e.g. the same data set collected over different years
# if 95% CI data is needed in merged data, there needs
# to be a way of preprocessing the names to make them
# unique. Not presently worth the time. No use case defined!

createDataseriesFromList = function(sourceTableList){
    # clean the names of the data.frames in sourceTableList
    sourceTableList = lapply(sourceTableList, FUN = cleanAsthmaTableNames)
    # can add table name cleaning step here
    for(i in 1:length(sourceTableList)){
        sourceTableList[[i]][, "Table.ID"] = names(sourceTableList)[[i]]
    }    
    # need to get rid of the 95% CI columns: Neither needed nor unique!
    sourceTableList = lapply(sourceTableList, FUN = function(x){
        colsToKeep = !grepl("95_CI", names(x))
        return(x[, colsToKeep])
    })
    # Seamlessly condense dataframe list: http://stackoverflow.com/questions/8091303/
    mergedTable = Reduce(function(...) merge(..., all=T), sourceTableList)    
    return(mergedTable)
}

# tested it using the Adult data series
adultOverallDataSeries = createDataseriesFromList(cleanAdultOverallTablesList)


