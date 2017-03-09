data_exp_help_01 = list()

# This is a nice little function that makes it to get a
# basic overview of a list of tables in a more concise
# (i.e. comppact) manner than summary() or head(). 
data_exp_help_01$getTableColAndClass = function(dataFrame){
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
    cat(stringPrefix, firstColNames, "and", paste0(lastColName, "."))
}

#
data_exp_help_01$conciseDataListSummary = function(dataList){
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
        data_exp_help_01$getTableColAndClass(dataList[[id]])
        cat(doubleSpace)
    }
}
