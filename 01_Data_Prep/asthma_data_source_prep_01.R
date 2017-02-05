

## Metadata table generation 

initAsthmaMetaData = function(){
    demographic = c("Overall", "Gender", "Age", 
        "Ethnicity", "Education", "Income")
    demID = c(1, 21, 3, 5, 6, 7)    
    asthmaMetaData = as.data.frame(cbind(demographic, demID), stringsAsFactor = F)
    return(asthmaMetaData)
}