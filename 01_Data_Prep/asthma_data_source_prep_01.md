# Asthma Data Component - Data Processing Strategy

Before commencing the project, it is a good idea to have a path towards efficiently acquiring and processing data, given the amount of it to be processed.

Main Page: https://www.cdc.gov/asthma/brfss/

Archive pages: https://www.cdc.gov/asthma/brfss/archive.htm

Note on the data: 
* The separate aggregation is slightly annoying, because the links between the different
* groups are broken - can't get combinations e.g. age, sex and state!
* Data is pre-stratified! --> possibly to deal with missin data

Therefore, it is a good idea to get multiple tables from multiple years, to represent different slices/perspectives of the data over time. This is reasonable, given that we don't know beforehand which slices will prove most useful. Blending the data may not be feasible, given that the data has <u>apparently</u> already been split and aggregated with no direct connections to the individual observations from which the data was drawn :disappointed:.

## Current Data: 2011 to 2014

### Overview

Looking at the data pertaining to this period of time, we notice that the base URL is:

**https://www.cdc.gov/asthma/brfss/**

The next component of the table is the **year** segment, followed by some sort of table designation:

Example: 

* 2014 Adult Lifetime Asthma by Age: https://www.cdc.gov/asthma/brfss/2014/tableL3.htm
* 2014 Child Lifetime Asthma by Age: https://www.cdc.gov/asthma/brfss/2014/child/tableL3.htm

Now, the first issue is that the adult and child tables have an important difference in the **child** segment of the URL, which is important to keep in mind.

The adult tables are divided into the following interesting segments:

* Gender (percent)
* Age group
* Race/Ethnicity (seems more informative than simply by Race)
* Education
* Income

However, the child tables only contain the following groups of interest:

* Gender (percent)
* Age group
* Race/Ethnicity

If we want to look at the potential trends in both datasets (and we do), we need to bear this in mind. Note that **education** and **income** data were not made available, presumably not collected.

Further, the datasets are split into two different measures, **lifetime** and **current**, which are defined in the [background information](https://www.cdc.gov/asthma/brfss/default.htm) as follows:

> **Lifetime** _asthma_ is defined as an affirmative response to the question “Have you ever been told by a doctor {nurse or other health professional} that you have asthma?”.
        
> **Current** _asthma_ is defined as an affirmative response to that question followed by an affirmative response to the subsequent question “Do you still have asthma?”.

Basically, these definitions equate to: 

* **lifetime**: used to have asthma at one time.
* **lifetime**: still have asthma now.

### Adult vs Child

Now that we have this background, lets get back to the table URLs. From the examples above, using 2014, we can generalise these "base" URL segments:

* 2014 Adult: https://www.cdc.gov/asthma/brfss/**2014**/ ...
* 2014 Child: https://www.cdc.gov/asthma/brfss/**2014**/child/ ...

to the following: 

* base Adult: https://www.cdc.gov/asthma/brfss/**yearID**/ ...
* base Child: https://www.cdc.gov/asthma/brfss/**yearID**/child/ ...

Basically, **yearID** is a placeholder for any year between 2011 and 2014 (inclusive).

Now we can process the 

### Demographic attributes

The demographic IDs for the attributes of interest are listed as follows:

| Demographic      | ID |
|------------------|:--:|
| Gender (percent) | 21 |
| Age              | 3  |
| Race/Ethnicity   | 5  |
| Education        | 6  |
| Income           | 7  |

Basically, these attribute names and IDs are, fortunately, identical for both adults and children. Let's call the demographic IDs **demID**, both for brevity and because this sounds like a good name for a variable :wink:. So, if we want to refer to demographic statistics for age for lifetime and current asthma, respectively, we can do so as follows:

* Lifetime: L**demID**
* Current: C**demID**

Lets consider current and lifetime as measures of asthma **recency**, we can call this variable **recID** and generalise the above situations to:

* **recIDdemID**

The best thing about this scenario is that because these demographic attributes are identical for both adults and children, they can be handled the same way :)

### Putting the pieces together

The analysis of the data sources above allows us to understand how to start the systematic acquisition and processing of the raw data pertaining to asthma prevalence for the period of time specified. Thus, during the period covering 2011 to 2014, the locations of tables for adults and children can be generalised as follows:

* generalised adult table: baseURL**/****yearID****/**table**recIDdemID**.htm/
* generalised child table: baseURL**/****yearID****/**child**/**table**recIDdemID**.htm/

This basically mean that we can write code to efficiently obtain all of the information for all of the tables that we require for both adults and children for the years between 2011 and 2014 (latest avaiable as at 04/02/2017) :smile:!

## Archive Data: 1999 to 2010

Note: Child data only exists from **2001** onwards!

but 2001, 2004 child is only overall, and is rather incomplete

### 2010
https://www.cdc.gov/asthma/brfss/2010/lifetime/tableL3.htm

https://www.cdc.gov/asthma/brfss/2010/child/lifetime/tableL3.htm

https://www.cdc.gov/asthma/brfss/2010/current/tableC3.htm

https://www.cdc.gov/asthma/brfss/2010/child/current/tableC3.htm

### 1999 to 2009

https://www.cdc.gov/asthma/brfss/09/lifetime/tableL3.htm

https://www.cdc.gov/asthma/brfss/09/current/tableC3.htm

https://www.cdc.gov/asthma/brfss/01/lifetime/child/tableL3.htm

future note: Need to check totals :smile: and also check table footnotes!

### Number vs. Percent

During the process of inspecting the data I looked at the structure of the data to see what I was in for, i.e. what variables would I need to extract from the data after harvesting them from the web.

It then dawned upon me that the state of the data was not quite what I thought it was. Basically, the **Sample size** variable is somehow used to create the **Prevalence
(percent)** variable. This would make sense, given that the prevalence would simply be the _number of asthma sufferers **in the study**_ <u>divided by</u> the sample size. 

Oddly, or so it would seem, the *Prevalence (number)* variable seems to be a calculation of the _number of asthma sufferers **in the regional population**_ using the *Prevalence
(percent)* variable and the *total* population of the region in question.

Number looked like the best option as percentages seemed to be derivative... but that doesn't look like the case, because the prevalence number is not the portion of the sample size that have asthma, it is the calculated estimate of the population of the region in question. 

Therefore we need to extract the number positive using the sample size and prevalence. (best guess) given that I don't have the data avaiable :disappointed:


This could be a problem, or you could simply use the prevalence number, and estimate the region's population based on that (acknowledging variances in correspondece to the totals).

No drama, simply calcuate BOTH the sample number and total population using the sample size and prevalence (number), respectively in combination with the population!

demo calcs :smile:



| Demographic      | ID |
|------------------|:--:|
| Overall          |  1 |

This gives an updated table:

| Demographic      | ID |
|------------------|:--:|
| Overall          |  1 |
| Gender (percent) | 21 |
| Age              | 3  |
| Race/Ethnicity   | 5  |
| Education        | 6  |
| Income           | 7  |

With this updated table, we can now programmatically reconstruct all of the URLs that we need to use in order to connect to anc acquire the data that we will use for analysis.

## Next Steps

Use of web scraping tools such as [rvest](https://blog.rstudio.org/2014/11/24/rvest-easy-web-scraping-with-r/) in combination with the knowledge gained above to generate script(s) to acquire and process the data for further analysis. :smile:


<br/>
