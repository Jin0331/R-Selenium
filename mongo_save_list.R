library(tidyverse)
library(mongolite)

db <- "indication_list"

mongoUrl <- "mongodb://root:sempre813!@192.168.0.91:27017/admin"
ena_list <- read_delim(file = "lung_1.tsv", delim = "\t", col_names = T) %>%
  bind_rows(., read_delim(file = "lung_2.tsv", delim = "\t", col_names = T)) %>%
  bind_rows(., read_delim(file = "lung_3.tsv", delim = "\t", col_names = T)) %>%
  # bind_rows(., read_delim(file = "MiaPaca2_4.tsv", delim = "\t", col_names = T)) %>%
  # bind_rows(., read_delim(file = "MiaPaca2_5.tsv", delim = "\t", col_names = T)) %>%
  # bind_rows(., read_delim(file = "MiaPaca2_6.tsv", delim = "\t", col_names = T)) %>%
  unique()

# ena_list <- read_delim(file = "WIDR.tsv", delim = "\t", col_names = T)



collection_name <- "LUNG"
m <- mongo(collection = collection_name, 
           db = db, 
           url = mongoUrl,
           verbose = TRUE, 
           options = ssl_options())
m$insert(ena_list)

