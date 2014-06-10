#!/usr/bin/Rscript

## Simple script to clean the data from ScraperWiki. ##

library(rjson)
library(RCurl)

# Load data using the ScraperWiki SQL API.
base_url <- 'https://ds-ec2.scraperwiki.com/zaflugd/iokwwtf3ldspuao/sql'

# The sql query should be made depending on the tables
# that you would like to visualize.
table_name <- 'hdx_repo_analytics'  # table name with the viz data.
sql_query <- paste('?q=select%20*%20from%20', table_name, sep = "")

# Getting a query url.
query_url <- getURL(paste(base_url, sql_query, sep = ""))

# getData function that fetches the JSON and
# parses is into a data.frame.
getData <- function() {
    b <- fromJSON(query_url)
    for (i in 1:length(b)) {
        c <- b[[i]]
        if (i == 1) d <- c
        else d <- cbind(d, c)
    }
    z <- data.frame(t(d))
    z
}
data <- getData()


### Visualization Specifig Handling ###
# The code below is indended to shape the data
# to match the needs of the specific visualization intended.

# In the example below we are fething activity data from
# the HDX Repo CKAN instance and preparing it for graphing with
# C3.js. C3 is loading the data from a CSV file for ease,
# but the same could be done directly from a JSON stream.

# Leave only the columns of interest
# and store the resulting objects into
# different CSV files.
number_datasets <- data.frame(as.numeric(data$Number_of_Datasets),
                              as.character(data$Date_and_Time))

other_data <- data.frame(as.numeric(data$Number_of_Organizations),
					 	as.numeric(data$Number_of_Users),
						as.character(data$Date_and_Time))

# Adding proper names
names(number_datasets) <- c('Number_of_Datasets', 'Date_and_Time')
names(other_data) <- c('Number_of_Organizations', 'Number_of_Users', 'Date_and_Time')

# Storing data.
write.csv(number_datasets, '~/tool/http/data/number_of_datasets.csv', row.names = FALSE)
write.csv(other_data, '~/tool/http/data/other_data.csv', row.names = FALSE)

cat('Data for chart has been refreshed.')