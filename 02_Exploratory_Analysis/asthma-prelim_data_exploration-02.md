# Asthma data: Preliminary Data Exploration 2

## Intro

Based on the [first look](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-01.md#further-cleanup) at the asthma dataset, the data preparation was [updated](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/01_Data_Prep/asthma_data_source_prep_02.Rmd#updates) to remove a number of the quirks in the dataset that would be unecessarily inconvenient to downstream data analysis. Another outcome of the update was the consolidation of the 10 processed asthma data subsets into a single table that was gzip compressed for space efficiency.

### Setup

The standard setup chunk for report generation... :alien:


```r
# Getting knitr to play ball
# http://stackoverflow.com/questions/24585254/working-with-knitr-using-subdirectories
require(knitr, quietly=TRUE)
opts_knit$set(root.dir = normalizePath("../"))
```

## Data exploration

### Data import

The setup of the data import is similar manner as in the [previous exploration](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-01.md#data-import). Fortunately, the **read_csv_quiet()** wrapper to **readr::read_csv()** handles compressed content without additional configuration.


```r
#### 1. Data Import ####
# import helper functions
helperParentDir = "./helper_scripts/"
source(file.path(helperParentDir, "01_data_prep/", "general_helpers_01.R"))
source(file.path(helperParentDir, "02_data_explore/", "helpers-prelim_data_explore_00.R"))

# Source data dir
asthmaDataDir = "./Data/asthma/series/"
asthmaGZipFile = file.path(asthmaDataDir, "asthma_data.csv.gz")

# readr handles compressed files automatically :)
asthmaData = gen_helpers_01$read_csv_quiet(asthmaGZipFile)
# but need to convert to data.frame ... tibble issues!
asthmaData = as.data.frame(asthmaData)
```

### Initial data snapshot

Now that we have gone back and tweaked the processing of the data we need to reexamine the data to make sure that we:

* haven't been caught out by any oddities introduced during cleaning.
* have properly cleaned the data prior to further exploration.


```r
knitr::kable(summary(asthmaData))
```

        State             SampleSize       Prev.perc      Prev.perc.SE         Group.ID              Year        Table.ID         Demographic        Dem.Category        PrevSize.est    
---  -----------------  ---------------  ---------------  -----------------  -----------------  -------------  -----------------  -----------------  -----------------  -----------------
     Length:45351       Min.   :     0   Min.   :  0.00   Length:45351       Length:45351       Min.   :2000   Length:45351       Length:45351       Length:45351       Min.   :    0.00 
     Class :character   1st Qu.:   397   1st Qu.:  8.10   Class :character   Class :character   1st Qu.:2004   Class :character   Class :character   Class :character   1st Qu.:   41.18 
     Mode  :character   Median :   927   Median : 10.70   Mode  :character   Mode  :character   Median :2008   Mode  :character   Mode  :character   Mode  :character   Median :   97.47 
     NA                 Mean   :  3055   Mean   : 11.35   NA                 NA                 Mean   :2007   NA                 NA                 NA                 Mean   :  330.16 
     NA                 3rd Qu.:  1952   3rd Qu.: 13.70   NA                 NA                 3rd Qu.:2011   NA                 NA                 NA                 3rd Qu.:  208.48 
     NA                 Max.   :496223   Max.   :100.00   NA                 NA                 Max.   :2014   NA                 NA                 NA                 Max.   :67524.38 
     NA                 NA               NA's   :36       NA                 NA                 NA             NA                 NA                 NA                 NA's   :36       

The summary above indicates that the classes of the data columns are now correctly processed :smile:... almost. **Prev.perc.SE** should also be numeric :confused:. In addition, **SampleSize** has a minimun value of zero, indicating that there might be data collection issues. Further, the other prevalence-related columns each contain 36 **NA**s, which might be related to the zero sample size observations.

However, this is a good step forward, now let's take a sneak [peak](https://twitter.com/_SneakPeak) (sic) at the data to see what our combined table looks like:


```r
knitr::kable(head(asthmaData))
```



State    SampleSize   Prev.perc  Prev.perc.SE   Group.ID    Year  Table.ID   Demographic   Dem.Category    PrevSize.est
------  -----------  ----------  -------------  ---------  -----  ---------  ------------  -------------  -------------
AK              101         5.4  1.84           adult       2005  C5         Ethnicity     Multirace NH           5.454
AK             1014         7.8  1.06           adult       2011  C6         Education     Some Coll             79.092
AK              102         9.5  2.67           adult       2005  L5         Ethnicity     Multirace NH           9.690
AK             1021        14.4  1.54           adult       2011  L6         Education     Some Coll            147.024
AK             1028        11.1  1.58           adult       2014  C3         Age           55-64                114.108
AK             1031        15.2  1.79           adult       2014  L3         Age           55-64                156.712

Overall, the data looks good... but let's take a look at these missing values in order to see what patterns or data characteristics may be responsible.

### Checking out the missing data


```r
knitr::kable(head(asthmaData[is.na(asthmaData$Prev.perc), ]), row.names = F)
```



State    SampleSize   Prev.perc  Prev.perc.SE   Group.ID    Year  Table.ID   Demographic   Dem.Category    PrevSize.est
------  -----------  ----------  -------------  ---------  -----  ---------  ------------  -------------  -------------
CT                0          NA                 adult       2002  C5         Ethnicity     Multirace NH              NA
CT                0          NA                 adult       2002  L5         Ethnicity     Multirace NH              NA
OH                0          NA                 adult       2002  C5         Ethnicity     Multirace NH              NA
OH                0          NA                 adult       2002  L5         Ethnicity     Multirace NH              NA
PR                0          NA                 adult       2002  C5         Ethnicity     Multirace NH              NA
PR                0          NA                 adult       2002  L5         Ethnicity     Multirace NH              NA

```r
unique(asthmaData[is.na(asthmaData$Prev.perc), "Dem.Category"])
```

```
## [1] "Multirace NH" "Black NH"
```

What are the characteristics of this NA data subset? The simplest way to get an idea is to create a custom summary table to extract the characteristics of the dataset that we need to examine.


```r
subsetCols = c("State", "Group.ID", "Year", "Table.ID", "Demographic", "Dem.Category")

uniqueNaEntryList = lapply(subsetCols, FUN = function(x, dataSet){
    c(x, length(unique(dataSet[, x])))
    df = data.frame()
    df[1, "Col.Name"] = x
    df[1, "Unique.Vals"] = length(unique(dataSet[, x]))
    df[1, "Val.Set"] = paste(sort(unique(dataSet[, x])), collapse=", ")
    return(df)
}, dataSet = asthmaData[is.na(asthmaData$Prev.perc), ])

uniqueNaEntries = Reduce( function(...) merge(..., all = T), uniqueNaEntryList)
knitr::kable(uniqueNaEntries)
```



Col.Name        Unique.Vals  Val.Set                                              
-------------  ------------  -----------------------------------------------------
Dem.Category              2  Black NH, Multirace NH                               
Demographic               1  Ethnicity                                            
Group.ID                  2  adult, child                                         
State                     3  CT, OH, PR                                           
Table.ID                  2  C5, L5                                               
Year                      9  2002, 2004, 2005, 2006, 2007, 2008, 2009, 2011, 2012 

Interestingly, we can see that the issues relating to NA values in the prevalence data columns seem to be related to the collection of data from certain ethnic groups from three specific states. This probably explains why the minimum sample size is zero in the summamry table. Notably, this potential issue spans a large number of the time period represented in the dataset.

This indicates that for the specific ethnic groups in the affected regions, at least **some** of the <u>data</u> is missing at least **some** of the <u>time</u>. However, this serves as a warning to take note of in future a analysis given that the data collection issues may be quite widespread, distorting the picture of asthma prevalence by ethnicity. This means that modelling of data pertaining to ethnicity (and probably other parameters) from this dataset may be affected by data collection bias. The fact that this data is basically pre-aggregated, means that we don't know, for example, if data pertaining to other demographic parameters (e.g. income) was collected from these individuals (possibly not).

This might mean that the overall dataset might not be a representative as we might hope, so this is important to keep in mind.

### Checking out the valid data entries

Now that we have a better understanding of some of the potential issues that form part of our input dataset. We need to consider these more in future, but let's clean the dataset up and see what we are dealing with.


```r
asthmaValidData = asthmaData[!is.na(asthmaData$Prev.perc), ]
knitr::kable(head(asthmaValidData))
```



State    SampleSize   Prev.perc  Prev.perc.SE   Group.ID    Year  Table.ID   Demographic   Dem.Category    PrevSize.est
------  -----------  ----------  -------------  ---------  -----  ---------  ------------  -------------  -------------
AK              101         5.4  1.84           adult       2005  C5         Ethnicity     Multirace NH           5.454
AK             1014         7.8  1.06           adult       2011  C6         Education     Some Coll             79.092
AK              102         9.5  2.67           adult       2005  L5         Ethnicity     Multirace NH           9.690
AK             1021        14.4  1.54           adult       2011  L6         Education     Some Coll            147.024
AK             1028        11.1  1.58           adult       2014  C3         Age           55-64                114.108
AK             1031        15.2  1.79           adult       2014  L3         Age           55-64                156.712

This is the same as what we have seen in the [initial snapshot](#initial-data-snapshot), but this is always a good thing to do after a potentially sigificant data op. What is more instructive is performing the same summary of the data's characteristics as we did [before](checking-out-the-missing-data):


```r
uniqueEntryList = lapply(subsetCols, FUN = function(x, dataSet){
    c(x, length(unique(dataSet[, x])))
    df = data.frame()
    df[1, "Col.Name"] = x
    df[1, "Unique.Vals"] = length(unique(dataSet[, x]))
    return(df)
}, dataSet = asthmaValidData)

uniqueValidEntries = Reduce( function(...) merge(..., all = T), uniqueEntryList)

knitr::kable(uniqueValidEntries)
```



Col.Name        Unique.Vals
-------------  ------------
Dem.Category             31
Demographic               6
Group.ID                  2
State                    57
Table.ID                 12
Year                     15

This table is pretty much what you would expect, given the fact that we saw this level of granularity in the source webpages. However, the thing to point out as part of this exploratory phase is the large number of permutations that would be involved in an attempt to plot all of the data as graphs. To give you an idea of the issue, we would need to plot a total of 31 demographic categories from 57 states and territories (note: number includes totals) over a 15 year period. Basically, we will end up with too many permutations to pursue with a forest of graphs.

### Conclusions

The most sensible strategy seems to be to start with exploratory visualisation of the agggregated data represented by the totals before diving into the different subsections. This top down approach lets the data direct our exploration of subsections of interest, and we will commence this process in the [next section](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-03.md).

<p style="text-align:center; border-style:solid;border-color:blue;">:smile: Back to [Project Readme](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/README.md#2-exploratory-data-analysis) :alien: Back to [the top]() :smile:</p><br/><br/>
