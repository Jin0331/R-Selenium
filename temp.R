collection_to_DF_context(db = "cellline", collection_name = "A549", url = mongoUrl) %>% 
  write_delim(file = "~/temp/A549.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "COLO201", url = mongoUrl) %>% 
  write_delim(file = "~/temp/COLO201.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "COLO205", url = mongoUrl) %>% 
  write_delim(file = "~/temp/COLO205.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "HCT15", url = mongoUrl) %>% 
  write_delim(file = "~/temp/HCT15.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "LIM1215", url = mongoUrl) %>% 
  write_delim(file = "~/temp/LIM1215.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "LS1034", url = mongoUrl) %>% 
  write_delim(file = "~/temp/LS1034.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "LS411N", url = mongoUrl) %>% 
  write_delim(file = "~/temp/LS411N.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "LS513", url = mongoUrl) %>% 
  write_delim(file = "~/temp/LS513.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "MiaPaca2", url = mongoUrl) %>% 
  write_delim(file = "~/temp/MiaPaca2.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "SW48", url = mongoUrl) %>% 
  write_delim(file = "~/temp/SW48.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "T84", url = mongoUrl) %>% 
  write_delim(file = "~/temp/T84.txt", delim = "\t")

collection_to_DF_context(db = "cellline", collection_name = "WIDR", url = mongoUrl) %>% 
  write_delim(file = "~/temp/WIDR.txt", delim = "\t")
