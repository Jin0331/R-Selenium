collection_to_DF_context(db = "cellline", collection_name = "SKMES1", url = mongoUrl) %>% 
  write_delim(file = "~/temp/temp.txt", delim = "\t")
