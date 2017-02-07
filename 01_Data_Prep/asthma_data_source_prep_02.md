# Asthma Data Preparation II - Data Processing Implementation

## Introduction

The strategy document oulined a useful strategy toward the systematic harvesting and processing of the different tables that make up the asthma prevalence dataset that we wish to analyse. To this end, one of the main things that the strategy detailed was the logic by which the individual URLs, that each represent data tables, could be programmatically reconstructed. This is very important because it allows us to reproducibly obtain and analyse this fairly extensive dataset in a **rule-based** manner. This in turn provides the flexibility that is required to: 

* integrate future datasets into this analysis as they become available.
* import and process specific subsets of the data should the whole dataset not be needed.

Given the number of functions that would be required to design a data processing framework that makes the strategy easy to follow, and therefore to debug, we will be relying on a combination of two types of scripts:

* **Analysis scripts:** Scripts that perform specific data preparation or analysis tasks on a specific set(s) of data in order to achieve a defined set of goals. Functions that are defined in these scripts are typically and ideally **specific** to the analysis being performed. More generalised functionality can be drawn from onr or more **helper scripts**.
* **Helper scripts:** A set of scripts that contain distinct parts of the functionality needed to perform a set of tasks. These helpers are called upon by **analysis scripts** where needed, in order to make the logic that drives analysis scripts cleaner and easier to follow and manage. The contents of a helper script contains generalised functionality that can be made easily available to muliple **analysis scripts**. 
    * Generalised functionality are basically common functions that perform routine tasks that often need to be performed in multiple scripts. 
    * Helper script files help to improve code (and functionality) reusability and management.

Another strategy that we are going to use is that of function lists. Basically, storing the helper functions within a list object is quite useful because it:

1) Helps to reduce the Global namespace footprint: lists reduce the number of objects that exist within the main namespace of the working environment, reducing the likelihood and impact of name conflicts. 
    * A small group of objects are easier to give unique names to a larger group.
    * This is of particular note, for example, when a number of external packages need to be loaded
2) enable ease of functionality management: i.e. easier removal of groups of functions when not required :wink:.

## Phase I: Metadata preparation

The first part of the process is metadata preparation. For the purposes of this section, metadata describes one or more tables (data.frames) that contain an organised set of URLs and related information.

The aim of this section is to create a family of functions to facilitate metadata preparation. 

## Phase II: Data processing from metadata



## Next Steps

Use of web scraping tools such as [rvest](https://blog.rstudio.org/2014/11/24/rvest-easy-web-scraping-with-r/) in combination with the knowledge gained above to generate script(s) to acquire and process the data for further analysis. :smile:

future note: Need to check table footnotes for "surprises" :wink:!

<br/>
