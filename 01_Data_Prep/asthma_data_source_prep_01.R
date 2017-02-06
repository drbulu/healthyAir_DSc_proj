#### Asthma Prevanence data: Data Preparation 1 ####

## 01 - Create list of tables of URLs to access

# i) import helper functions
source("./01_Data_Prep/helpers-asthma_data_01-url_table_prep.R")

# ii) create metadata tables of required URLS
asthma_URL_table_list = asthma_helper_func_01$createAsthmaURLTables()

# iii) remove list of helpers when no longer required
rm(asthma_helper_func_01)

## 02 - Obtain the data relating to the contents of the URL tables in step 01


