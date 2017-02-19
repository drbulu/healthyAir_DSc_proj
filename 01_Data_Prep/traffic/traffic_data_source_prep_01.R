#### Traffic Monitoring data: Data Preparation 1 ####

## 00 - Load required helper functions
helperParentDir = "./helper_scripts/01_data_prep/"
source(file.path(helperParentDir, "general_helpers_01.R"))
source(file.path(helperParentDir, "helpers-traffic_data_prep_01.R"))
source(file.path(helperParentDir, "helpers-traffic_data_prep_02.R"))

## 01 - Extract metadata information form data source

# i) Create list of tables of URLs to access using data source
trafficMainPage = "https://www.fhwa.dot.gov/policyinformation/travel_monitoring/tvt.cfm"
rawTableList = gen_helpers_01$getHTMLtables(trafficMainPage)

# ii) Merge list of URL tables information into a single metadata file
# the last table (# 16) is not needed. Represents unusable dataset
trafficURLMetadata = traffic_helpers_01$checkAndMergeTableList(rawTableList[1:15])

## 02 - Cleanup the URL entry metadata in the merged table
trafficURLMetadata = traffic_helpers_01$cleanTrafficURLtable(trafficURLMetadata)

## 03 - Download excel files for further processing

# More useful to download the files before subsequent processing
# download files from processed table. Store download paths in
# metadata for later use.
rawDataDir = "./Data/traffic/raw/"
trafficURLMetadata$Local.XLS = paste0(rawDataDir, trafficURLMetadata$XLS.File)

traffic_helpers_01$downloadFilesFromTable(urlTable = trafficURLMetadata,
    dataDir = rawDataDir, subsetREGEX = "XLS")

## 04 - Process downloaded files into a single master file

# Taking the option to consolidate all the data into a single file for later exploration
combinedTrafficDataFrame = traffic_helpers_02$processFileMetadata(trafficURLMetadata, isList = F)

## 05 - Download file as CSV 
tidyDataDir = "./Data/traffic/tidy/"
# create dataDir with any subdirs    
if (!dir.exists(tidyDataDir)) dir.create(tidyDataDir, recursive = T)
write.csv(
    x = combinedTrafficDataFrame,
    file = paste0(tidyDataDir, "traffic-combined_data.csv"),
    row.names = F)