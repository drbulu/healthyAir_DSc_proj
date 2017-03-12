#### Asthma Prevanence data: Data Preparation 1 ####

## 01 - Create list of tables of URLs to access

# i) import helper functions
helperParentDir = "./helper_scripts/01_data_prep/"
source(file.path(helperParentDir, "helpers-asthma_data_01-url_table_prep.R"))

# ii) create metadata tables of required URLS
asthma_URL_table_list = asthma_helpers_01$createAsthmaURLTables()

# iii) remove list of helpers when no longer required

## 02 - Obtain the data relating to the contents of the URL tables in step 01
source(file.path(helperParentDir, "helpers-asthma_data_02-url_data_prep.R"))

# get sets of data from the web using list of metadata tables!
# simple wrapper function for convenience
getAsthmaDataTableLists = function(asthmaURLTableList){
    # create a list of data lists (data.frame lists)
    dataTableList = lapply(asthmaURLTableList, 
        FUN=asthma_helpers_02$getDatasetTablesFromURL)    
    return(dataTableList)
}

asthmaListofDataTableLists = getAsthmaDataTableLists(asthma_URL_table_list)    

## 03 - Prepare and merge the data obtained from the previous step to 
# create list of Asthma data series

createDataSeriesList = function(dataTableList){
    # find and process the names of the Adult L21 tables
    # from 2001 and 2002. These caused much grief before.
    preppeddataTableList = lapply(dataTableList, 
        FUN=asthma_helpers_02$preprocAdultGenderL21)    
    # Make the data series list - fully processed data
    asthmaDataSeriesList = lapply(preppeddataTableList, 
        FUN=asthma_helpers_02$createDataseriesFromList)
    return(asthmaDataSeriesList)
}

asthmaDataSeriesList = createDataSeriesList(asthmaListofDataTableLists)

## 04 - Prepare and merge the data obtained from the previous step to 
# create list of Asthma data series

asthmaDataSeriesList = asthma_helpers_02$reformatDataSeriesList(dataSeriesList = asthmaDataSeriesList)

asthmaDataSet = asthma_helpers_02$createTidyAsthmaData(dataSeriesList = asthmaDataSeriesList)

## 05 - Save data to disk for further analysis!
asthmaDataDir = "./Data/asthma/series/"
asthmaGZipFile = file.path(asthmaDataDir, "asthma_data.csv.gz")
gen_helpers_01$gzipDataFile(dataFrame = asthmaDataSet, gzPath = asthmaGZipFile)

## 06 - cleanup: remove helper function lists
rm(asthma_helpers_01, asthma_helpers_02)