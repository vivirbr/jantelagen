library(pxweb)
library(tidyverse)

Sys.setlocale(locale="UTF-8") 

d <- pxweb_interactive("api.scb.se")

# Download data 
px_data <- pxweb_get(url = d$url,
                     query = d$query)

# Convert to data.frame 
px_data_frame <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")

px_data_comments <- pxweb_data_comments(px_data)
