library(mongolite)
library(tidyverse)

mongoUrl <- "mongodb://root:sempre813!@192.168.0.91:27017/admin"

collection_to_DF_context(db = "indication_center_name_paper", collection_name = "LUSC", url = mongoUrl) %>% 
  write_delim(file = "/home/wmbio/selenium/result/LUSC.txt", delim = "\t")
