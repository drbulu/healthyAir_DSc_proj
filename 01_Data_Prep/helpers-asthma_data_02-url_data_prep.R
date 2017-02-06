

# now to convert the data frame constructed by prepAsthmaYearURLsByID()
# to create a list of data frames

# from brief inspection of source code for a couple of the tables
# Desired HTML element type: <table>
# table class: class="opt-in table table-bordered"

# options: 
# XML: http://stackoverflow.com/questions/1395528/scraping-html-tables-into-r-data-frames-using-the-xml-package#1401367
# rvest: https://www.r-bloggers.com/using-rvest-to-scrape-an-html-table/
# useful: http://stackoverflow.com/questions/28729507/scrape-multiple-linked-html-tables-in-r-and-rvest
# rvest seems to be the way forward (more modern and flexible?)
# Docs: https://cran.r-project.org/web/packages/rvest/
# https://blog.rstudio.org/2015/09/24/rvest-0-3-0/
# will try non-"tidyverse" oldschool syntax first :)

# how to get table
getTableHTML = function(url) if (require(rvest)) return(html_table(read_html(url), header = NA, fill = T))

# need to extract target table in getTableHTML() to make lapply() manageable.
b = lapply( y[,4], getTableHTML)


