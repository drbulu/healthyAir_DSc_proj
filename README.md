---
title: "Healthy Air: Project README"
output:
  html_document:
    toc: true
    toc_depth: 4
---

<!-- Markdown rendering doesn't produce a nice TOC: harvested it from the HTML version -->
<div class="fluid-row" id="header">
<h1 class="title toc-ignore">Healthy Air: Project README</h1>
</div>

<div id="TOC">
<ul>
<li><a href="#introduction">Introduction</a><ul>
<li><a href="#about">About</a></li>
<li><a href="#background-summary">Background summary:</a></li>
<li><a href="#hypothesis">Hypothesis:</a></li>
</ul></li>
<li><a href="#project-structure">Project Structure</a><ul>
<li><a href="#overview">Overview</a></li>
<li><a href="#1-data-preparation">1: Data preparation</a></li>
<li><a href="#2-exploratory-data-analysis">2: Exploratory data analysis</a></li>
<li><a href="#3-statistical-analysis-and-data-modelling">3: Statistical analysis and data modelling</a></li>
<li><a href="#4-predictive-modelling-and-machine-learning">4: Predictive modelling and machine learning</a></li>
<li><a href="#5-data-products">5: Data products</a></li>
</ul></li>
</ul>
</div>

## Introduction

### About

This is a data science project to investigate how respiratory health evolves and its relationship with the type and production of various pollutants. Also of interest is the impact of other factors that may define or influence this relationship.

### Background summary:

Respiratory ailments such as [asthma](https://en.wikipedia.org/wiki/Asthma) constitute an important long term public health concern (some background [here](https://en.wikipedia.org/wiki/Asthma)). Asthma has been linked to a number of factors including particulates <sup>[a](http://europepmc.org/abstract/med/7492903)</sup> <sup>[b](http://www.tandfonline.com/doi/abs/10.1080/00039896.1993.9938391)</sup>, extreme [weather events](http://www.abc.net.au/news/2016-11-22/two-die-in-thunderstorm-asthma-emergency-in-melbourne/8044558 ) and even [economic status](http://www.tandfonline.com/doi/abs/10.1080/00039896.1967.10664708).

### Hypothesis: 

The basic hypotheses that guide this project are that:

* Respirtory health in a given region varies over time and is influenced by the production of certain pollutants.

* The quantities of these pollutants are in turn linked to particular economic activities

* The relationship between respiratory health and pollution is affected by other underlying elements such as meterological and demographic factors.

## Project Structure

### Overview

These hypotheses will be evaluated through judicious analysis of potentially useful [open data](https://en.wikipedia.org/wiki/Open_data), from which important insights and relationships can be extracted and utilised. The following general framework represents the different groups of activities that will be used to investigate the hypothesis, communicate the results and leverage insights gained from the analysls:

<!-- as section nav -->

1. Raw data aquisition and preparation

2. Exploratory data analysis

3. Statistical analysis and modelling

4. Prediction modelling and machine learning

5. The development of reports and other data products

The following sections contain links to project documents pertaining to each part of the framework:

### 1: Data preparation

1. Asthma Data:

    This dataset captures the prevalence of asthma over time in the US by region, stratified by region (state) a number of potentially interesting groups. This is the quantity (response variable) that we are interested in predicting in the context of other factors.

    * Data preparation [strategy](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/01_Data_Prep/asthma_data_source_prep_01.Rmd) overview.
    * Data preparation [implemetation](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/01_Data_Prep/asthma_data_source_prep_02.Rmd) overview. <b style="color:red;">Updated</b> based on preliminary data analysis below.

2. Traffic Data:

    This data measures rural and urban traffic volumes (in millions of vehicle miles) and is also stratified by region.

    * Data preparation [strategy and implemetation](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/01_Data_Prep/traffic_data_source_prep_01.Rmd) overview.

3. Pollution Data:

    This data set is a representation of the trends in the emission of seven pollutants by different activities across different states in the US over time.

    * Data preparation [strategy and implemetation](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/01_Data_Prep/pollution_data_source_prep_01.Rmd) overview.

### 2: Exploratory data analysis

#### A. Preliminary
Exploratory analysis using graphs and other visualisation tools is quite exciting and insightful. However, sometimes we need to perform the comparatively boring task of checking the success and completeness of our data. 

Therefore, before we get to the exciting task of constructing exploratory visualisations, we need to check how complete the data preparation is thus far. This will enable us to read in our data correctly prior to subsequent analysis, and will help to highlight any quirks to beware of or any further processing that might be required prior to analysis.

Conceivably, the results of this stage of the analysis could be fed back into the data preparation step in order implement further refinements as required.

<!-- needed to convert the exploratory analysis files to markdown (md)... github doesn't process RMarkdonw (Rmd)... sheepish :) -->

1. Asthma Data:

* [Preliminary data analysis 01](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-01.md): First look at processed asthma data sets.
* [Preliminary data analysis 02](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-02.md): Analysis of the impact of data processing improvements.
* [Graphical data exploration](https://github.com/drbulu/healthyAir_DSc_proj/blob/master/02_Exploratory_Analysis/asthma-prelim_data_exploration-03.md): Initial examination of broad trends in aggregate data.

2. Traffic Data:

* Analysis in progress...

3. Pollution Data:

* Analysis in progress...

#### B. In depth


### 3: Statistical analysis and data modelling



### 4: Predictive modelling and machine learning



### 5: Data products


