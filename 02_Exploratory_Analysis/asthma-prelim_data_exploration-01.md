# Asthma data: Preliminary Data Exploration

## Intro

This document is a first look at the previously processed asthma dataset.

<ul>
    <li><a href="#intro">Intro</a><ul>
    <li><a href="#setup">Setup</a></li>
    <li><a href="#exploration-tools">Exploration tools</a></li>
</ul></li>
    <li><a href="#data-exploration">Data exploration</a>
    <ul>
        <li><a href="#data-import">Data import</a></li>
        <li><a href="#initial-data-snapshot">Initial data snapshot</a></li>
    </ul></li>
    <li><a href="#prelim-conclusions">Prelim conclusions</a>
    <ul>
        <li><a href="#exploration-summary">Exploration summary</a></li>
        <li><a href="#further-cleanup">Further cleanup</a></li>
        </ul>
    </li>
    <li><a href="#appendix">Appendix</a>
    <ul>
    <li><a href="#comparison-of-data-frame-list-snapshot-options">Comparison of data frame list snapshot options</a></li>
    </ul></li>
</ul>

### Setup

In the [data preparation phase](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/01_Data_Prep/asthma_data_source_prep_02.Rmd), we were able to scrape together a number of tables from the web and save them to disk as CSV files. 

We are using **knitr** with RStudio to document this exploration. Therefore, the following chunk of code (**```configChunk```**) is quite important. This is because knitr normally sets the root directory as the working directory, which is inconvenient for us as this (and most other) RMarkdown files are located in project subdirectories. What is not readily appreciable is that this default behavious renders our file paths, which are relative to the parent project directory (the R project working directory), are rendered invalid. The solution, as it happens, is quite simple and is shown below. 


```r
# Getting knitr to play ball
# http://stackoverflow.com/questions/24585254/working-with-knitr-using-subdirectories
require(knitr, quietly=TRUE)
opts_knit$set(root.dir = normalizePath("../"))
```

### Exploration tools

Before diving into the data, I did a little prototyping in the script **asthma-exploratory_notes-01.R**. One of the things that I wanted to do was a brief comparison of the performance of read_csv() (readr) and read.csv() (utils). 

For what we are looking for, the notable difference between read_csv() function from the [readr](https://github.com/tidyverse/readr) package and read.csv() in the base [utils](https://cran.r-project.org/doc/manuals/r-release/R-data.html#Variations-on-read_002etable) package... readr functions can guess column types. This is useful, but leaves you quite at the mercy of the function's internal logic. 

The simplest solution to avoid this is to set the **guess_max** argument to <u>zero</u>. This has the advantage of quickly reading in all data as character variables, which you then have to reclass yourself. Howver, this means that any wierd type coersion will be <u>your</u> fault, not readr's :wink:. Other useful args to take not of are **skip** and **n_max**.

One other thing that I did notice was that readr::read_csv() was able to guess the type of columns containing numbers with commas as thousands separators but these appeared as character in read.csv(). This was a good data processing heads up which gave me a reminder of the need to better understand the structure of the data and possible processing implications. 

## Data exploration

### Data import

I imported the prepared asthma dataset data using the code in the chunk below. Note, the functionality prototyping that I did in **asthma-exploratory_notes-01.R** was to create helpers (as is my wont) to neaten up the primary analysis code. Generally useful functions, such as **getCsvDataListFromDir()**, were moved to **general_helpers_01.R** while some of the other functionality in this chunk exists in **helpers-asthma_data_explore_00.R** (generally useful for data summary).


```r
#### 1. Data Import ####

# import helper functions
helperParentDir = "./helper_scripts/"
source(file.path(helperParentDir, "01_data_prep/", "general_helpers_01.R"))
source(file.path(helperParentDir, "02_data_explore/", "helpers-prelim_data_explore_00.R"))

# Source data dir
asthmaDataDir = "./Data/asthma/series/"

asthmaDataList = gen_helpers_01$getCsvDataListFromDir(asthmaDataDir)
```

### Initial data snapshot
The **conciseDataListSummary()** function below was designed to give a very brief and compact summary of a potentially large list of data.frames, with the specific purpose of scoping out each data.frame for the names and data types of all the columns. 

The following output would be a lot more compact than running **head()** or **str()** as the output would rapidly become problematic. This is slightly more informative than **names()**, which only returns the column names for a given data.frame. For more a comparison of the options, skip the [appendix](#appendix)

**<a id="table-1">Table 1</a>:**


```r
# go through the data.frame list and print out the names and classs
# of each column from each data.frame in the list.
data_exp_help_01$conciseDataListSummary(asthmaDataList)
```

```
## Table 1 of 10. Name: adult_age. rows (9796), cols (9) .................... 
## Column Names (Class):  State (character), AgeGroup (character), SampleSize (numeric), Prev.perc (numeric), Prev.perc.SE (character), Prev.num (numeric), Group.ID (character), Year (integer) and Table.ID (character).
## 
## Table 2 of 10. Name: adult_education. rows (6540), cols (9) .................... 
## Column Names (Class):  State (character), Education (character), SampleSize (numeric), Prev.perc (numeric), Prev.perc.SE (character), Prev.num (numeric), Group.ID (character), Year (integer) and Table.ID (character).
## 
## Table 3 of 10. Name: adult_ethnicity. rows (8036), cols (9) .................... 
## Column Names (Class):  State (character), Ethnicity (character), SampleSize (numeric), Prev.perc (character), Prev.perc.SE (character), Prev.num (numeric), Group.ID (character), Year (integer) and Table.ID (character).
## 
## Table 4 of 10. Name: adult_gender. rows (1656), cols (10) .................... 
## Column Names (Class):  State (character), MaleSampleSize (character), Male.Prev.perc (character), Male.Prev.perc.SE (character), FemaleSampleSize (character), Female.Prev.perc (character), Female.Prev.perc.SE (character), Group.ID (character), Year (integer) and Table.ID (character).
## 
## Table 5 of 10. Name: adult_income. rows (8168), cols (9) .................... 
## Column Names (Class):  State (character), Income (character), SampleSize (numeric), Prev.perc (numeric), Prev.perc.SE (character), Prev.num (numeric), Group.ID (character), Year (integer) and Table.ID (character).
## 
## Table 6 of 10. Name: adult_overall. rows (1656), cols (8) .................... 
## Column Names (Class):  State (character), SampleSize (character), Prev.perc (character), Prev.perc.SE (character), Prev.num (character), Group.ID (character), Year (integer) and Table.ID (character).
## 
## Table 7 of 10. Name: child_age. rows (2748), cols (9) .................... 
## Column Names (Class):  State (character), AgeGroup (character), SampleSize (numeric), Prev.perc (numeric), Prev.perc.SE (character), Prev.num (numeric), Group.ID (character), Year (integer) and Table.ID (character).
## 
## Table 8 of 10. Name: child_ethnicity. rows (3284), cols (9) .................... 
## Column Names (Class):  State (character), Ethnicity (character), SampleSize (numeric), Prev.perc (numeric), Prev.perc.SE (character), Prev.num (numeric), Group.ID (character), Year (integer) and Table.ID (character).
## 
## Table 9 of 10. Name: child_gender. rows (702), cols (10) .................... 
## Column Names (Class):  State (character), MaleSampleSize (character), Male.Prev.perc (character), Male.Prev.perc.SE (character), FemaleSampleSize (character), Female.Prev.perc (character), Female.Prev.perc.SE (character), Group.ID (character), Year (integer) and Table.ID (character).
## 
## Table 10 of 10. Name: child_overall. rows (702), cols (8) .................... 
## Column Names (Class):  State (character), SampleSize (character), Prev.perc (character), Prev.perc.SE (character), Prev.num (character), Group.ID (character), Year (integer) and Table.ID (character).
```

Let's take a look at the first table in the table list ([Table 1](#table-1)), to get an idea of the composition of the data:


```r
knitr::kable(head(asthmaDataList[[1]], 5))
```



State   AgeGroup    SampleSize   Prev.perc  Prev.perc.SE    Prev.num  Group.ID    Year  Table.ID 
------  ---------  -----------  ----------  -------------  ---------  ---------  -----  ---------
AK      18-24              198         8.1  2.63                4535  adult       2000  C3       
AK      25-34              413         4.3  1.45                4148  adult       2000  C3       
AK      35-44              569         4.6  1.06                5229  adult       2000  C3       
AK      45-54              481         8.5  1.69                7069  adult       2000  C3       
AK      55-64              213        13.1  4.17                6447  adult       2000  C3       

Seems pretty straight forward, the contents of each column seems to be as one would expect given the column name, except for the **Prev.perc.SE** column. This column contains numbers (numeric) but is set to character. Let's explore this further to see what structure (i.e. anomalies or artefacts) of the data might be responsible for this data type misclassification.

The **summary()** is a powerful function to drill down into a data.frame to get a picture of what is going on. So, let's summarise it to see what is going on...


```r
knitr::kable(summary(asthmaDataList[[1]]))
```

        State             AgeGroup           SampleSize       Prev.perc     Prev.perc.SE          Prev.num         Group.ID              Year        Table.ID       
---  -----------------  -----------------  ---------------  --------------  -----------------  ----------------  -----------------  -------------  -----------------
     Length:9796        Length:9796        Min.   :    46   Min.   : 0.80   Length:9796        Min.   :     83   Length:9796        Min.   :2000   Length:9796      
     Class :character   Class :character   1st Qu.:   537   1st Qu.: 8.10   Class :character   1st Qu.:  19778   Class :character   1st Qu.:2003   Class :character 
     Mode  :character   Mode  :character   Median :   884   Median :10.20   Mode  :character   Median :  48024   Mode  :character   Median :2007   Mode  :character 
     NA                 NA                 Mean   :  2237   Mean   :10.79   NA                 Mean   : 146032   NA                 Mean   :2007   NA               
     NA                 NA                 3rd Qu.:  1465   3rd Qu.:12.80   NA                 3rd Qu.:  97593   NA                 3rd Qu.:2011   NA               
     NA                 NA                 Max.   :157922   Max.   :33.50   NA                 Max.   :6278309   NA                 Max.   :2014   NA               
     NA                 NA                 NA's   :28       NA's   :28      NA                 NA's   :28        NA                 NA             NA               

The **Prev.perc.SE** column is summarised as a character variable, as we expect. This, however, doesn't help us to figure out where the problem is. What might help us though, is the fact that all of the numeric columns (Year is an integer) each have 28 NA values. Our question then becomes this:

> "Is there something in common between the 28 NA rows in the numeric columns and the fact that the Prev.perc.SE, which should also be numeric, is classed as a character?"

To answer this, let's see what is going on with the NAs:


```r
adult_age_na_subset = asthmaDataList[[1]][is.na(asthmaDataList[[1]]$SampleSize), ]
knitr::kable(head(adult_age_na_subset))
```



State         AgeGroup    SampleSize   Prev.perc  Prev.perc.SE    Prev.num  Group.ID    Year  Table.ID 
------------  ---------  -----------  ----------  -------------  ---------  ---------  -----  ---------
Territories                       NA          NA                        NA  adult       2001  C3       
Territories                       NA          NA                        NA  adult       2002  C3       
Territories                       NA          NA                        NA  adult       2003  C3       
Territories                       NA          NA                        NA  adult       2004  C3       
Territories                       NA          NA                        NA  adult       2005  C3       
Territories                       NA          NA                        NA  adult       2006  C3       

When we cast our minds back to the raw data tables, the "Territories" label is actually a subheading that differentiates between the 50 states of the US and the associated territories. The next thing to do is to find out and confirm what values of the **State** variable are represent these NA rows:


```r
unique( adult_age_na_subset$State[is.na(adult_age_na_subset$SampleSize)] )
```

```
## [1] "Territories"
```

To confirm that we have identified the source of the type conversion issues throughout the asthma dataset (all data.frames in the list), let's briefly profile another data frame in the list:


```r
adult_income_na_subset = asthmaDataList[[5]][is.na(asthmaDataList[[5]]$SampleSize), ]
knitr::kable(head(adult_income_na_subset))
```



State         Income    SampleSize   Prev.perc  Prev.perc.SE    Prev.num  Group.ID    Year  Table.ID 
------------  -------  -----------  ----------  -------------  ---------  ---------  -----  ---------
Territories                     NA          NA                        NA  adult       2001  C7       
Territories                     NA          NA                        NA  adult       2002  C7       
Territories                     NA          NA                        NA  adult       2003  C7       
Territories                     NA          NA                        NA  adult       2004  C7       
Territories                     NA          NA                        NA  adult       2005  C7       
Territories                     NA          NA                        NA  adult       2006  C7       

```r
unique(asthmaDataList[[5]]$State)
```

```
##  [1] "AK"           "AL"           "AR"           "AZ"          
##  [5] "CA"           "CO"           "CT"           "DC"          
##  [9] "DE"           "FL"           "GA"           "GU"          
## [13] "HI"           "IA"           "ID"           "IL"          
## [17] "IN"           "KS"           "KY"           "LA"          
## [21] "MA"           "MD"           "ME"           "MI"          
## [25] "MN"           "MO"           "MS"           "MT"          
## [29] "NC"           "ND"           "NE"           "NH"          
## [33] "NJ"           "NM"           "NV"           "NY"          
## [37] "OH"           "OK"           "OR"           "PA"          
## [41] "PR"           "RI"           "SC"           "SD"          
## [45] "Territories"  "TN"           "TX"           "U.S. Total**"
## [49] "US Total"     "UT"           "VA"           "VI"          
## [53] "VT"           "WA"           "WI"           "WV"          
## [57] "WY"
```

Just to be sure:


```r
# number of rows where the "SampleSize" (numeric) column's value is NA
nrow( asthmaDataList[[5]][is.na(asthmaDataList[[5]]$SampleSize), ] )
```

```
## [1] 28
```

```r
# number of rows where the "State" column's value is "Territories"
nrow( asthmaDataList[[5]][ asthmaDataList[[5]]$State == "Territories", ] )
```

```
## [1] 28
```

Seems pretty convincing to me!

Let's have a look at all of the State names to see what else might be going on:


```r
unique(asthmaDataList[[1]]$State)
```

```
##  [1] "AK"           "AL"           "AR"           "AZ"          
##  [5] "CA"           "CO"           "CT"           "DC"          
##  [9] "DE"           "FL"           "GA"           "GU"          
## [13] "HI"           "IA"           "ID"           "IL"          
## [17] "IN"           "KS"           "KY"           "LA"          
## [21] "MA"           "MD"           "ME"           "MI"          
## [25] "MN"           "MO"           "MS"           "MT"          
## [29] "NC"           "ND"           "NE"           "NH"          
## [33] "NJ"           "NM"           "NV"           "NY"          
## [37] "OH"           "OK"           "OR"           "PA"          
## [41] "PR"           "RI"           "SC"           "SD"          
## [45] "Territories"  "TN"           "TX"           "U.S. Total**"
## [49] "US Total"     "UT"           "VA"           "VI"          
## [53] "VT"           "WA"           "WI"           "WV"          
## [57] "WY"
```

These should probably look like this:


```r
gsub("U(.)*S(.)*", "US TOTAL", unique(asthmaDataList[[1]]$State))
```

```
##  [1] "AK"          "AL"          "AR"          "AZ"          "CA"         
##  [6] "CO"          "CT"          "DC"          "DE"          "FL"         
## [11] "GA"          "GU"          "HI"          "IA"          "ID"         
## [16] "IL"          "IN"          "KS"          "KY"          "LA"         
## [21] "MA"          "MD"          "ME"          "MI"          "MN"         
## [26] "MO"          "MS"          "MT"          "NC"          "ND"         
## [31] "NE"          "NH"          "NJ"          "NM"          "NV"         
## [36] "NY"          "OH"          "OK"          "OR"          "PA"         
## [41] "PR"          "RI"          "SC"          "SD"          "Territories"
## [46] "TN"          "TX"          "US TOTAL"    "US TOTAL"    "UT"         
## [51] "VA"          "VI"          "VT"          "WA"          "WI"         
## [56] "WV"          "WY"
```

This pattern seems to be a feature of all of the datasets, so this is something that we need to fix before further exploration :smile:. However, we might still want to succinctly capture the meta infomration associated with asterisks (*) in the "U.S. Total**" labels. Basically, we might want to be aware of which summaries have been flagged <u>without</u> having to add another column to the entire dataset to account for a potentially small number of observations. The asterisks seem to represent the following note about how the [national totals](https://www.cdc.gov/asthma/brfss/2014/tableL1.htm) are calculated:

> "**U.S. Total includes 50 states plus the District of Columbia and excludes the three territories."

This is important to keep in mind, but hardly worthy of a separate column... or is it?


```r
adult_age = asthmaDataList$adult_age
starTotalRows = nrow(adult_age[adult_age$State == "U.S. Total**", ])
nonStarTotalRows = nrow(adult_age[adult_age$State == "US Total", ])
totalRowContrib = (starTotalRows + nonStarTotalRows)/ nrow(adult_age) * 100
 
starYears = adult_age$Year[adult_age$State == "U.S. Total**"]
nonStarYears = adult_age$Year[adult_age$State == "US Total"]
```

For example, in the adult age data (adult_age) rows we find that of the 9796 observations, 168 and 12 rows match the "U.S. Total**" () and "US Total" **State** descriptions, respectively. Rows labelled "U.S. Total**" are associated with the years between 2001 and 2014. While those labelled "US Total" were found only in the year 2000.

For this reason, and because the total rows constitute only **1.84** % of the data in this table, we will no be adding a separate column to capture the information represented by the asterisks. Instead, we can standardise these labels a little so that the US Total rows can be extracted efficiently despite the asterisks in some observations. To enable this selection, we can probably do something like this to make them otherwise identical to the non-flagged total rows :wink::


```r
gsub("U(.)*S(.)*[Tt]otal", "US Total", unique(asthmaDataList[[1]]$State))
```

```
##  [1] "AK"          "AL"          "AR"          "AZ"          "CA"         
##  [6] "CO"          "CT"          "DC"          "DE"          "FL"         
## [11] "GA"          "GU"          "HI"          "IA"          "ID"         
## [16] "IL"          "IN"          "KS"          "KY"          "LA"         
## [21] "MA"          "MD"          "ME"          "MI"          "MN"         
## [26] "MO"          "MS"          "MT"          "NC"          "ND"         
## [31] "NE"          "NH"          "NJ"          "NM"          "NV"         
## [36] "NY"          "OH"          "OK"          "OR"          "PA"         
## [41] "PR"          "RI"          "SC"          "SD"          "Territories"
## [46] "TN"          "TX"          "US Total**"  "US Total"    "UT"         
## [51] "VA"          "VI"          "VT"          "WA"          "WI"         
## [56] "WV"          "WY"
```

## Preliminary analysis conclusions

Main takehome: The asthma dataset looks reasonabley clean but needs some work to make it totaly [tidy](http://vita.had.co.nz/papers/tidy-data.pdf).

### Exploration summary

Based on the analysis that we have performed above, it looks like the asthma data set is reasonably clean. Encouragingly, readr::**read_csv()** should be able to neatly handle the classes of the input data that was generated during data processing. However, there are a number of things that we could (and really should) do to clean up the data prior to exploration and analysis.

### Further cleanup

The data is neat, but still has a little way to go before being tidy. Important things to note include:

1. Cleanup of sample rows. This will have the downstream benefit of removing spurions entries and simultaneously making it much easier to correctly assign data types to the processed data upon subsequent import:

    * remove entries where the "State" column has the text "Territories". This is a simple but useful step that really shouldn't have to be dealt with later
    * Standardising the national summary data in the rows where "State" is "US Total" or "U.S. Total"


```r
# total row count (all tables in list) - (est NA row count * number of tables)
estTotalDataSize = sum( sapply(asthmaDataList, FUN = nrow) ) - (28 * 10)
```

2. Further standardise the column names of all the input datasets to enable efficient:

    * storage and retrieval of data as single file.
    * extraction of different information subsets from the whole dataset.
    * The total data size is approximately **43008** rows, which large but quite manageable in the grand scheme of things. There are a multitude of strategies to efficiently handle large files in R and such options are discussed [here](http://stackoverflow.com/a/9353181) and [here](http://stackoverflow.com/a/1728422).

In order to condense all 10 tables into a single, uniform table, we would need to standardise the number and type of columns such that ALL tables are identically formatted. One way of compacting the data into a single file would be to add the following columns to the dataset: 

| Demographic | Dem.Category | PrevSize.est |
|-------------|--------------|--------------|
| Overall     | Summary      |       ?      |
| Age         | 18-24        |       ?      |

The **Demographic** column would capture the information presently captured in columns such as **AgeGroup** or **Income** column names. The column containing the demographic information could then be renamed to **Dem.Category**. The third proposed column, **PrevSize.est**, is optional and is derived from the product of the **SampleSize** and **Prev.perc** columns. This is simple to calculate, but it's potential convenience in later analysis may justify its inclusion during data processing.

3. On the topic of State names, we do need to create a metadata reference containg state information such as State name, abbreviation and other potentially useful information. To obtain this information we can simply obtain the tables such as [this](https://en.wikipedia.org/wiki/List_of_states_and_territories_of_the_United_States) one and [this](https://en.wikipedia.org/wiki/List_of_U.S._states_and_territories_by_area) one by webscraping :smile:. Such metadata would be quite valuable, given that other datasets in this project (e.g the traffic data) contain full name description of states and not abbreviations as in the case with this data. We would then need a way of translating between the full names and abbreviations.

Let's see what the [next section](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-02.md) has in store for us :smile:.

<p style="text-align:center;">Back to [Project Readme](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/README.md#2-exploratory-data-analysis) :smile:</p>

## Appendix

### Comparison of data frame list snapshot options

To compare the effect, we will use the first data.frame in the list (**adult_age**), to compare output, since the other functions above don't work on data.frame lists without "help".

Our handy function, which also provides other metadata such as the name of the list element index linked to the table, and its dimensions (row and col count)


```r
data_exp_help_01$conciseDataListSummary(asthmaDataList[1])
```

```
## Table 1 of 1. Name: adult_age. rows (9796), cols (9) .................... 
## Column Names (Class):  State (character), AgeGroup (character), SampleSize (numeric), Prev.perc (numeric), Prev.perc.SE (character), Prev.num (numeric), Group.ID (character), Year (integer) and Table.ID (character).
```

vs. names()

```r
names(asthmaDataList[[1]])
```

```
## [1] "State"        "AgeGroup"     "SampleSize"   "Prev.perc"   
## [5] "Prev.perc.SE" "Prev.num"     "Group.ID"     "Year"        
## [9] "Table.ID"
```

vs. head()


```r
head(asthmaDataList[[1]])
```

```
## # A tibble: 6 × 9
##   State AgeGroup SampleSize Prev.perc Prev.perc.SE Prev.num Group.ID  Year
##   <chr>    <chr>      <dbl>     <dbl>        <chr>    <dbl>    <chr> <int>
## 1    AK    18-24        198       8.1         2.63     4535    adult  2000
## 2    AK    25-34        413       4.3         1.45     4148    adult  2000
## 3    AK    35-44        569       4.6         1.06     5229    adult  2000
## 4    AK    45-54        481       8.5         1.69     7069    adult  2000
## 5    AK    55-64        213      13.1         4.17     6447    adult  2000
## 6    AK      65+        190       7.0         2.09     2548    adult  2000
## # ... with 1 more variables: Table.ID <chr>
```

vs. str()


```r
str(asthmaDataList[[1]])
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	9796 obs. of  9 variables:
##  $ State       : chr  "AK" "AK" "AK" "AK" ...
##  $ AgeGroup    : chr  "18-24" "25-34" "35-44" "45-54" ...
##  $ SampleSize  : num  198 413 569 481 213 190 299 510 750 687 ...
##  $ Prev.perc   : num  8.1 4.3 4.6 8.5 13.1 7 7.3 5.5 7.4 10 ...
##  $ Prev.perc.SE: chr  "2.63" "1.45" "1.06" "1.69" ...
##  $ Prev.num    : num  4535 4148 5229 7069 6447 ...
##  $ Group.ID    : chr  "adult" "adult" "adult" "adult" ...
##  $ Year        : int  2000 2000 2000 2000 2000 2000 2001 2001 2001 2001 ...
##  $ Table.ID    : chr  "C3" "C3" "C3" "C3" ...
##  - attr(*, "problems")=Classes 'tbl_df', 'tbl' and 'data.frame':	84 obs. of  4 variables:
##   ..$ row     : int  3925 3925 3925 3926 3926 3926 3927 3927 3927 3928 ...
##   ..$ col     : chr  "SampleSize" "Prev.perc" "Prev.num" "SampleSize" ...
##   ..$ expected: chr  "a number" "a double" "a number" "a number" ...
##   ..$ actual  : chr  "" " " "" "" ...
##  - attr(*, "spec")=List of 2
##   ..$ cols   :List of 9
##   .. ..$ State       : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ AgeGroup    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ SampleSize  : list()
##   .. .. ..- attr(*, "class")= chr  "collector_number" "collector"
##   .. ..$ Prev.perc   : list()
##   .. .. ..- attr(*, "class")= chr  "collector_double" "collector"
##   .. ..$ Prev.perc.SE: list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ Prev.num    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_number" "collector"
##   .. ..$ Group.ID    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ Year        : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ Table.ID    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   ..$ default: list()
##   .. ..- attr(*, "class")= chr  "collector_guess" "collector"
##   ..- attr(*, "class")= chr "col_spec"
```

**summary()** is also a useful function

```r
summary(asthmaDataList[[1]])
```

```
##     State             AgeGroup           SampleSize       Prev.perc    
##  Length:9796        Length:9796        Min.   :    46   Min.   : 0.80  
##  Class :character   Class :character   1st Qu.:   537   1st Qu.: 8.10  
##  Mode  :character   Mode  :character   Median :   884   Median :10.20  
##                                        Mean   :  2237   Mean   :10.79  
##                                        3rd Qu.:  1465   3rd Qu.:12.80  
##                                        Max.   :157922   Max.   :33.50  
##                                        NA's   :28       NA's   :28     
##  Prev.perc.SE          Prev.num         Group.ID              Year     
##  Length:9796        Min.   :     83   Length:9796        Min.   :2000  
##  Class :character   1st Qu.:  19778   Class :character   1st Qu.:2003  
##  Mode  :character   Median :  48024   Mode  :character   Median :2007  
##                     Mean   : 146032                      Mean   :2007  
##                     3rd Qu.:  97593                      3rd Qu.:2011  
##                     Max.   :6278309                      Max.   :2014  
##                     NA's   :28                                         
##    Table.ID        
##  Length:9796       
##  Class :character  
##  Mode  :character  
##                    
##                    
##                    
## 
```

<p style="text-align:center;">Back to [the top]() :smile:</p>
