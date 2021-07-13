library(tidyverse)
library(mongolite)

mongoUrl <- "mongodb://root:sempre813!@192.168.0.91:27017/admin"
# ena_list <- read_delim(file = "R-Selenium/prostate1.tsv", delim = "\t", col_names = T) %>%
#   bind_rows(., read_delim(file = "R-Selenium/prostate2.tsv", delim = "\t", col_names = T)) %>% 
# bind_rows(., read_delim(file = "R-Selenium/head_and_neck3.tsv", delim = "\t", col_names = T)) %>% 
# unique()

ena_list <- read_delim(file = "R-Selenium/list/cellline/snu739.tsv", delim = "\t", col_names = T)

collection_name <- "SNU739"
m <- mongo(collection = collection_name, 
           db = "cellline_list", 
           url = mongoUrl,
           verbose = TRUE, 
           options = ssl_options())
m$insert(ena_list)
