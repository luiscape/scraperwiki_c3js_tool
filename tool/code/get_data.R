#!/usr/bin/Rscript

## Simple script to clean the data from ScraperWiki. ##

library(rjson)
library(RCurl)

# Load data using the ScraperWiki SQL API.
url <- getURL('https://ds-ec2.scraperwiki.com/zaflugd/iokwwtf3ldspuao/sql?q=select%20*%20from%20hdx_repo_analytics')
getData <- function() { 
    b <- fromJSON(url)
    for (i in 1:length(b)) { 
        c <- b[[i]]
        if (i == 1) d <- c
        else d <- cbind(d, c)
    }
    z <- data.frame(t(d))
    z
}
data <- getData()


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
write.csv(number_datasets, 'http/data/number_of_datasets.csv', row.names = FALSE)
write.csv(other_data, 'http/data/other_data.csv', row.names = FALSE)