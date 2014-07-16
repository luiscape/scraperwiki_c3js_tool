#!/usr/bin/Rscript

library(rjson)
library(RCurl)

## Simple script to clean the data directly from CKAN / HDX Repo. ##

base_url <- 'http://data.hdx.rwlabs.org/api/action/'
api_action <- 'package_search'  # lists all the datasets with accompanying metadata.
result_limit <- '?rows='
offset_url <- '&start='

# getData function that fetches the JSON and
# parses is into a data.frame.
getData <- function(verbose = FALSE) {
    message('Preparing to query data.hdx.rwlabs.org...')
    simple_query_url <- getURL(paste(base_url, api_action, sep = ""))
    dataset_count <- fromJSON(simple_query_url)$result$count
    if (dataset_count > 1000) {
        n_offset_it <- ceiling(dataset_count / 1000)
    }
    for (i in 1:n_offset_it) {
        offset_n <- ifelse(i == 1, 0, (1000 * (i - 1)) + 1)
        query_url <- paste(base_url,
                           api_action,
                           result_limit,
                           1000,
                           offset_url,
                           offset_n,
                           sep = "")
        if (verbose == TRUE) print(query_url)  # debug
        url_data <- getURL(query_url)
        b <- fromJSON(url_data)$result$results
        # main iteration
        message(paste(i, 'out of', n_offset_it, 'iterations.'))
        pb <- txtProgressBar(min = 0, max = length(b), char = ".", style = 3)
        for (j in 1:length(b)) {
            setTxtProgressBar(pb, j)
            c <- b[[j]]$organization
            if (j == 1) d <- c
            else d <- cbind(d, c)
        }
        e <- data.frame(t(d))
        if (i == 1) z <- e
        else z <- rbind(z, e)
    }
    z
}
data <- suppressWarnings(getData(verbose = FALSE))


# simple analysis
total = nrow(data)
# dc65f72e-ba98-40aa-ad32-bec0ed1e10a2 = ourairports
# b74dee39-1737-4784-83f6-644544b7a295 = interaction
datasets_from_hdx = nrow(data[data$id == 'hdx' | data$id == 'dc65f72e-ba98-40aa-ad32-bec0ed1e10a2' | data$id == 'b74dee39-1737-4784-83f6-644544b7a295', ])
datasets_from_others = total - datasets_from_hdx

# in percentage
datasets_from_hdx = round((datasets_from_hdx / total) * 100, digits = 1)
datasets_from_others = round((datasets_from_others / total) * 100, digits = 1)

# writing CSV
write.csv(datasets_from_hdx, '~/tool/http/data/datasets_from_hdx.csv', row.names = FALSE)
write.csv(datasets_from_others, '~/tool/http/data/datasets_from_others.csv', row.names = FALSE)
