
epa_help_prep_01 = list()

## A - Create metadata file

# metadata cols: type, Entity, Desc 

epa_help_prep_01$epaCreateStateMetadata = function(epaData){
    # metadata construction blueprint
    metaTypeList = list(
        State = c("STATE_ABBR", "STATE_FIPS"),
        Source = c("tier1_code", "tier1_description"),
        Pollutant = c("pollutant_code") )
    metaDataNames = c("Type", "Entity", "Description")
    # process metadata
    metaDataList = list()
    for(i in names(metaTypeList)){
        # get basic metadata: unique combinations of components
        entryData = unique(epaData[, metaTypeList[[i]] ])
        if(i == "State") entryData$STATE_FIPS = paste0("FIPS_CODE=", 
            entryData$STATE_FIPS)
        if(i == "Pollutant"){
            entryData = data.frame(entryData, stringsAsFactors = F)
            entryData$Description = "unit=1000 tons"  
        } 
        names(entryData) = metaDataNames[2:3]
        entryData$Type = i
        metaDataList[[i]] = entryData[, metaDataNames]
    }
    return( Reduce( function(...) merge(..., all = T), metaDataList) )
}

## B - Process data file

# Transpose the imported raw data into a form more amenable to
# exploratory analysis, with Year data as a separate column.
# requires input data transposition via matrix functionality.

epa_help_prep_01$epaTransposeStateData = function(epaData){
    # easier to have nested functions for niche functionality
    # a) convert headings from emissionsYY to Year (YYYY) format
    sub_help_prepYear = function(x){
        x = gsub("emissions", "", x)
        y = format(as.Date(paste0("01/01/", x), format = "%d/%m/%y" ), "%Y")
        return(y)
    }
    # b) transpose data: http://stackoverflow.com/questions/6645524/
    transposeDf = function(dataFrame){
        matrix = t(dataFrame[, 2:ncol(dataFrame)])
        colnames(matrix) <- dataFrame[, 1]
        return (as.data.frame(matrix, stringsAsFactors = F))
    }
    
    epaData$ItemCode = paste(epaData$STATE_ABBR, epaData$tier1_code, 
        epaData$pollutant_code, sep = ".")
    
    eData = epaData[, c("ItemCode", grep("emissions[0-9]+", names(epaData), value=T)) ]
    eData[nrow(eData)+1, ] = names(eData)
    # add Year metadata prior to data transposition
    eData[nrow(eData), 1] = "Year"
    eData[nrow(eData), 2:length(eData)] = sub_help_prepYear( eData[nrow(eData), 2:length(eData)] )
    # eData[2, length(eData)] = sub_help_prepYear( eData[2, length(eData)] )
    # transpose and return formatted data
    eData = transposeDf(eData)
    # nifty name reordering. Move Year from last to first col
    sortedNames = c("Year", grep("year", names(eData), 
        ignore.case = T, invert = T, value = T))
    row.names(eData) = NULL
    return(eData[, sortedNames])
}
