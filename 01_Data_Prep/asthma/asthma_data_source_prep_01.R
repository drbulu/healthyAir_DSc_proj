#### Asthma Prevanence data: Data Preparation 1 ####

## 01 - Create list of tables of URLs to access

# i) import helper functions
source("./01_Data_Prep/helpers/helpers-asthma_data_01-url_table_prep.R")

# ii) create metadata tables of required URLS
asthma_URL_table_list = asthma_helper_func_01$createAsthmaURLTables()

# iii) remove list of helpers when no longer required
rm(asthma_helper_func_01)

## 02 - Obtain the data relating to the contents of the URL tables in step 01

source("./01_Data_Prep/helpers/helpers-asthma_data_02-url_data_prep.R")

# get sets of data from the web using list of metadata tables!
# simple wrapper function for convenience
getAsthmaDataTableLists = function(asthmaURLTableList){
    # create a list of data lists (data.frame lists)
    dataTableList = lapply(asthmaURLTableList, 
        FUN=asthma_helper_func_02$getDatasetTablesFromURL)    
    return(dataTableList)
}

asthmaListofDataTableLists = getAsthmaDataTableLists(asthma_URL_table_list)    

## 03 - Prepare and merge the data obtained from the previous step

preprocessAndMergeData = function(dataTableList){
    # find and process the names of the Adult L21 tables
    # from 2001 and 2002. These caused much grief before.
    preppeddataTableList = lapply(dataTableList, 
        FUN=asthma_helper_func_02$preprocAdultGenderL21)    
    # Make the data series list - fully processed data
    asthmaDataSeriesList = lapply(asthmaListofDataTableList, 
        FUN=asthma_helper_func_02$createDataseriesFromList)
    return(asthmaDataSeriesList)
}

asthmaDataSeriesList = preprocessAndMergeData(asthmaListofDataTableLists)

## 04 - Save files to disc for further analysis!
# probably in a common data dir!

# file save function: should probably be a helper, since it can
# generally handle a simple named list of data.frames and loop
# through said list and create a group of auto-named CSV files.
# note: this function requires a named list
saveDataListCsv = function(dataList, dataDir = "./", overwrite=F){
    # create dataDir with any subdirs    
    if (!dir.exists(dataDir)) dir.create(dataDir, recursive = T)
    # helper to create file path
    prepFilePath = function(n, dirName){
        n = gsub("( )+", "_", n)
        fileName = paste0(tolower(gsub("\\.", "_", n)), ".csv")
        return(paste(dirName, fileName, sep="/"))
    }
    # write dataList elements to CSV using element name to derive filename
    # noEcho is a lazy attempt to not echo a null list to console. write.csv()
    # returns NULL/void.
    noEcho = lapply(names(dataList), FUN=function(x, y){ write.csv(x = y[[x]], 
        file = prepFilePath(x, dataDir), row.names = F) }, dataList)    
}

# writing 
asthmaDataDir = "./Data/asthma/series/"

saveDataListCsv(asthmaDataSeriesList, asthmaDataDir)

rm(asthma_helper_func_02)