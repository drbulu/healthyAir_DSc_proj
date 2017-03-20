# Asthma data: Preliminary Data Exploration 3 - Graphical Summary

## Intro

Following from the [previous section](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-02.md) we are going to create graphical summaries of the aggregate data (totals) to get an overall shape of the dataset.

### Setup

In the [data preparation phase](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/01_Data_Prep/asthma_data_source_prep_02.Rmd), we were able to scrape together a number of tables from the web and save them to disk as CSV files. 


```r
# Getting knitr to play ball
# http://stackoverflow.com/questions/24585254/working-with-knitr-using-subdirectories
require(knitr, quietly=TRUE)
# working directory in which knitr evaluates code. Default = file's location.
opts_knit$set(root.dir = normalizePath("../"))
# Note: the paths below depend on the "root.dir" above!
# https://yihui.name/knitr/options/#package-options
# where the plots will be generated
figDir = "../Fig"
# in which subdirectory/analysis section is this file located?
workingSubdir = "02_Exploratory_Analysis"
opts_knit$set(base.dir = file.path(figDir, workingSubdir))
# URL sorting - linked to the base.dir path config
baseURL = paste0("https://github.com/drbulu/healthyAir_DSc_proj/", 
    "blob/master/")
opts_knit$set(base.url = paste0(baseURL, "Fig/", workingSubdir, "/"))
```

## Data exploration

### Data import

As per out [standard protocol](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-02.md) :smile:.


```r
#### 1. Data Import ####
# import helper functions
helperParentDir = "./helper_scripts/"

library(ggplot2); library(grid); library(gridExtra)

source(file.path(helperParentDir, "01_data_prep/", "general_helpers_01.R"))
source(file.path(helperParentDir, "02_data_explore/", "helpers-asthma_data_explore_plots_01.R"))

# Source data dir
asthmaDataDir = "./Data/asthma/series/"
asthmaGZipFile = file.path(asthmaDataDir, "asthma_data.csv.gz")

# readr handles compressed files automatically :)
asthmaData = gen_helpers_01$read_csv_quiet(asthmaGZipFile)
# but need to convert to data.frame ... tibble issues!
asthmaData = as.data.frame(asthmaData)
```

### Initial data snapshot

Then: try to plot data:

Groups (2): Adult and Child, by Demographic (6) across Time (15 years)

State level (50 states) granularity needs different strategy to condense exploratory vis over time. a) raw numbers b) relative to value in current year (0) previous years are either higher or lower!.
What vis types?

.......

```r
asthmaExplorePlots = data_exp_asthma_01$asthaPlotExploreGroup(asthmaData)
sort(names(asthmaExplorePlots))
```

```
##  [1] "adult_age"       "adult_education" "adult_ethnicity"
##  [4] "adult_gender"    "adult_income"    "adult_overall"  
##  [7] "child_age"       "child_ethnicity" "child_gender"   
## [10] "child_overall"
```

### Graphs by Demographic Category

#### Age


```r
ageGraphList = grepl("age", names(asthmaExplorePlots))
grid.draw(arrangeGrob(grobs = asthmaExplorePlots[ageGraphList], ncol = 1))
```

![](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/Fig/02_Exploratory_Analysis/asthma-prelim_data_exploration-03_files/figure-html/ageExploreGraphs-1.png)<!-- -->

#### Ethnicity


```r
ethnicGraphList = grepl("ethnicity", names(asthmaExplorePlots))
grid.draw(arrangeGrob(grobs = asthmaExplorePlots[ethnicGraphList], ncol = 1))
```

![](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/Fig/02_Exploratory_Analysis/asthma-prelim_data_exploration-03_files/figure-html/ethnicExploreGraphs-1.png)<!-- -->

#### Gender


```r
genderGraphList = grepl("gender", names(asthmaExplorePlots))
grid.draw(arrangeGrob(grobs = asthmaExplorePlots[genderGraphList], ncol = 1))
```

![](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/Fig/02_Exploratory_Analysis/asthma-prelim_data_exploration-03_files/figure-html/genderExploreGraphs-1.png)<!-- -->

#### Income


```r
incomeGraphList = grepl("income", names(asthmaExplorePlots))
grid.draw(arrangeGrob(grobs = asthmaExplorePlots[incomeGraphList], ncol = 1))
```

![](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/Fig/02_Exploratory_Analysis/asthma-prelim_data_exploration-03_files/figure-html/incomeExploreGraphs-1.png)<!-- -->

#### Education


```r
educationGraphList = grepl("education", names(asthmaExplorePlots))
grid.draw(arrangeGrob(grobs = asthmaExplorePlots[educationGraphList], ncol = 1))
```

![](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/Fig/02_Exploratory_Analysis/asthma-prelim_data_exploration-03_files/figure-html/educationExploreGraphs-1.png)<!-- -->

#### Overall


```r
overallGraphList = grepl("overall", names(asthmaExplorePlots))
grid.draw(arrangeGrob(grobs = asthmaExplorePlots[overallGraphList], ncol = 1))
```

![](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/Fig/02_Exploratory_Analysis/asthma-prelim_data_exploration-03_files/figure-html/overallExploreGraphs-1.png)<!-- -->

[next section](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-04.md).

<p style="text-align:center; border-style:solid;border-color:blue;">:smile: Back to [Project Readme](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/README.md#2-exploratory-data-analysis) :alien: Back to [the top]() :smile:</p><br/><br/>
