#### Asthma Prevanence data: Data Preparation 1 ####

## 01 - Create list of tables of URLs to access

# i) import helper functions
source("./01_Data_Prep/helpers-asthma_data_01-url_table_prep.R")

# ii) create metadata tables of required URLS
asthma_URL_table_list = asthma_helper_func_01$createAsthmaURLTables()

# iii) remove list of helpers when no longer required
rm(asthma_helper_func_01)

## 02 - Obtain the data relating to the contents of the URL tables in step 01

source("./01_Data_Prep/helpers-asthma_data_02-url_data_prep.R")

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

rm(asthma_helper_func_02)