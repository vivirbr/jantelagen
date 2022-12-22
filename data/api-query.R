library(pxweb)
library(tidyverse)

Sys.setlocale(locale="UTF-8") 

https://api.scb.se/OV0104/v1/doris/en/ssd/
https://api.scb.se/OV0104/v1/doris/en/ssd/BE

https://api.scb.se/OV0104/v1/doris/en/ssd/BE/BE0101/BE0101A/BefolkningNy  #

https://api.scb.se/OV0104/v1/doris/en/ssd/BE/BE0101/BE0101A/BefolkningNy #download demographics pop

d <- pxweb_interactive("api.scb.se")

# Download data 
px_data <- pxweb_get(url = "https://api.scb.se/OV0104/v1/doris/en/ssd/EN/EN0105/EN0105A/ElAnvSNI2007ArN",
                     query = "jantelagen/data/query.json")

# Convert to data.frame 
px_data_frame <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")

View(head(px_data_frame,100))
