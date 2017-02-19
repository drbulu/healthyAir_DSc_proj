#### Asthma Prevanence data: Data Preparation 1 ####

## 00 - Load required helper functions
helperParentDir = "./helper_scripts/01_data_prep/"
source(file.path(helperParentDir, "general_helpers_01.R"))
source(file.path(helperParentDir, "helpers-epa_data_prep_01.R"))

## 01 - Download Excel file from URL

# Prepare data directory
epaRawDataDir = "./Data/pollution/raw/"
gen_helpers_01$createTargetDir(epaRawDataDir)

# download file to data dir from URL
epaStatSummary = "https://www.epa.gov/sites/production/files/2016-12/state_tier1_90-16.xls"
epaSummaryDataPath = paste0(epaRawDataDir, gen_helpers_01$getURLFileName(epaStatSummary))
gen_helpers_01$downloadFileURL(targetURL = epaStatSummary, 
    destPath = epaSummaryDataPath, printMsg = T, delay = 0.25)

## 02 - Extract Data Sheet from Excel file

# Identify sheet names using: gen_helpers_01$excel_sheets_quiet(epaSummaryDataPath)
epaStateSummary = gen_helpers_01$read_excel_quiet(path = epaSummaryDataPath, 
    sheet = "state_trends", skip = 1)

## 03 - Prepare data for exploratory analysis

## Note: The data is pretty straight forward, the challenge is to
## make it available with minimum processing for exploratory analysis

# simplest solution, transform data into 2 forms:
# a) metadata: containing descriptions of data elements
epa_state_meta = epa_help_prep_01$epaCreateStateMetadata(epaStateSummary)

# b) data: contains the relevant information in an appropriate format. i.e. Years are NOT 
# cool note: unique works on data.frame objects :)
epa_state_data = epa_help_prep_01$epaTransposeStateData(epaStateSummary)

## 05 - Save Processed data and metadata to file as CSV 
tidyDataDir = "./Data/pollution/tidy/"

# save metadata
gen_helpers_01$saveAsCsv(dataFrame = epa_state_meta, 
    dirName = tidyDataDir, 
    fileName = "epa-state_trend-meta.csv")

# save transposed data
gen_helpers_01$saveAsCsv(dataFrame = epa_state_data, 
    dirName = tidyDataDir, 
    fileName = "epa-state_trend-data.csv")