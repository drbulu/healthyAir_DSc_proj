# Asthma Data Exploration - Scratch pad

# A little space to help work thorugh the functionality used in the RMarkdown 
# files docummenting the exploratory analysis of the Asthma data

#### 0. Testing file reading options ####

## Note: read_csv and read_tsv can read in text as well as files.... useful!
require(readr)

speedReadr = proc.time()
x = read_csv("./Data/asthma/series/adult_age.csv")
x1 = read_csv("./Data/asthma/series/adult_age.csv", guess_max = 0)
speedReadr = proc.time() - speedReadr

speedUtils = proc.time()
y = read.csv("./Data/asthma/series/adult_age.csv", stringsAsFactors = F)
speedUtils = proc.time() - speedUtils

speedReadr['elapsed']

speedUtils['elapsed']

rm(x,y)

#### 1. Data Import ####

# Source data dir
asthmaDataDir = "./Data/asthma/series/"

# note: the file name pattern is "group_demographic.csv" e.g "adult_age.csv"
asthmaDataFiles = grep("(*)+\\.csv$", dir(asthmaDataDir), value = T)

# note: readr seems to be able to read directly from zipped files without unzip()
getCsvDataListFromDir = function(dirName){
    require(readr)
    dataList = list()
    dataFiles = grep("(*)+\\.csv$", dir(dirName), value = T)
    for(fileName in dataFiles){
        filePrefix = gsub("\\.csv$", "", fileName)
        dataList[[filePrefix]] = read_csv(file = file.path(dirName, fileName))    
    }
    return(dataList)
}

asthmaDataList = getCsvDataListFromDir(asthmaDataDir)

## this is a similar function but with a more verbose form.
## Will call this in the Appendix
showDataListSummary = function(dataList){
    dataCount = length(dataList)
    singleSpace = "\n"
    doubleSpace = "\n\n"
    ellipses = paste(rep(".", 20), collapse = "")
    for(id in 1:dataCount){
        dataDim = dim(dataList[[id]])
        tableIntroMsg = paste0("Table ", id, " of ",
            dataCount, ". Name: ", names(dataList)[id],
            ". rows (", dataDim[1], "), cols (", dataDim[2], ") ", ellipses)
        cat( tableIntroMsg , "\n")
        ## named list of col classes
        # or list of names with classes in brackets!
        # useful even before you start getting into head() and summary()
        # cat(singleSpace)
        print( names(dataList[[id]]) )
        # cat(singleSpace)
        # print( head( dataList[[id]] ) )
        cat(singleSpace)
        # print( summary( dataList[[id]] ) )
        # cat(doubleSpace)
    }
}

# Get named vector of data.frame classes and Name of 
x = sapply(1:ncol(asthmaData[[1]]), FUN = function(x){
    nameID = names(asthmaData[[1]])[x]
    class( as.data.frame(asthmaData[[1]])[, x ]) 
    })
names(x) = sapply(1:ncol(asthmaData[[1]]), FUN = function(x){
    nameID = names(asthmaData[[1]])[x]
})

y = sapply(1:ncol(asthmaData[[1]]), FUN = function(x){
    nameID = names(asthmaData[[1]])[x]
})

getTableColAndClass = function(dataFrame){}
## Nice summary: - Needs a little work to pretty it up!

# This is a nice little function that makes it to get a
# basic overview of a list of tables in a more concise
# (i.e. comppact) manner than summary() or head(). 
getTableColAndClass = function(dataFrame){
    # obtain col names and classes from data Frame
    numCol = ncol(dataFrame)
    colNameSet = sapply(1:numCol, FUN = function(x){
        nameID = names(dataFrame)[x]
    })
    colClassSet = sapply(1:numCol, FUN = function(x){
        class( as.data.frame(dataFrame)[, x ])
    })
    # prep annotated column names
    annotColNames = paste(colNameSet, paste0("(", colClassSet , ")"))
    # separate the last col name for easy printing
    collapseChar = ", "
    lastColID = length(annotColNames)
    firstColNames = paste(annotColNames[1:(lastColID - 1)], collapse=collapseChar)
    lastColName = annotColNames[lastColID]
    # print neatly to console using print
    stringPrefix = "Column Names (Class): "
    cat(stringPrefix, firstColNames, "and", lastColName, ".")
}
