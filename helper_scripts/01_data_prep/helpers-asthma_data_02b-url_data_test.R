# Data Processing helpers - Test functionality for future reference!


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

asthma_helper_test_func_02 = list()


## 3. 

# reduce merge() http://stackoverflow.com/questions/8091303/
# Reduce(function(...) merge(..., all=T), list.of.data.frames)

# handy test function
asthma_helper_test_func_02$getDataListSlice = function(dataList, subset = 1, merge=T){
    y = lapply(dataList, FUN = function(x) return(x[subset,]) )
    if (merge) return( Reduce(function(...) merge(..., all=T), y))
    else return (y)    
}



