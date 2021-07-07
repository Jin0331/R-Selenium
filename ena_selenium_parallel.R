library(RSelenium)
library(tidyverse)
library(parallel)
library(mongolite)

# function
min_max_chunk <- function(ena_list, C){
  chunk <- function(x, n) split(x, sort(rank(x) %% n))
  
  ena_list <- 1:ena_list
  chunk(ena_list, C) %>% lapply(X = ., function(value){
    return(c(min(value), max(value)))
  }) %>% unname() %>% return()
}
collection_to_DF <- function(collection_name, url) {
  m <- mongo(collection = collection_name, 
             db = "indication", 
             url = url,
             verbose = TRUE, 
             options = ssl_options())
  m$find() %>% as_tibble() %>% return()
}
ena_parse <- function(remDr, ena_url, id, sleep_cnt = 4){
  
  remDr$navigate(paste0(ena_url, id))
  Sys.sleep(sleep_cnt)
  
  # tryCatch()
  title <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[2]')
  title <- title$getElementText() %>% unlist()
  
  study_accession <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[4]/div/div[2]/app-read-file-links/div/div[3]/table/tbody/tr/td[1]/div/span/a')
  study_accession <- study_accession$getElementText() %>% unlist()
  
  organism <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[3]/div[1]/div[2]/a')
  organism <- organism$getElementText() %>% unlist()
  
  sample_accession <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[3]/div[2]/div[2]/span')
  sample_accession <- sample_accession$getElementText() %>% unlist()
  
  instrument_model <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[3]/div[4]/div[2]/span')
  instrument_model <- instrument_model$getElementText() %>% unlist()
  
  read_count <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[3]/div[5]/div[2]/span')
  read_count <- read_count$getElementText() %>% unlist()
  
  base_count <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[3]/div[6]/div[2]/span')
  base_count <- base_count$getElementText() %>% unlist()
  
  library_layout <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[3]/div[8]/div[2]')
  library_layout <- library_layout$getElementText() %>% unlist()
  
  library_strategy <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[3]/div[9]/div[2]/span')
  library_strategy <- library_strategy$getElementText() %>% unlist()
  
  library_source <- remDr$findElement(using = "xpath", '//*[@id="view-content-col"]/div[3]/div[10]/div[2]')
  library_source <- library_source$getElementText() %>% unlist()
  
  tibble(title = title,
         study_accession = study_accession, 
         organism = organism, 
         sample_accession = sample_accession,
         instrument_model = instrument_model, 
         read_count = read_count, 
         base_count = base_count, 
         library_layout = library_layout,
         library_strategy = library_strategy, 
         library_source = library_source) %>% 
    return()
}
run_parse <- function(remDr, ena_url, id, collection_name, start, end){
  remDr$open() 
  remDr$navigate("https://www.ebi.ac.uk/ena/browser/home")
  Sys.sleep(10)
  cnt <- start
  while(cnt <= end){
    print(paste0(run_id[cnt], " #", cnt))
    re <- FALSE
    tryCatch(
      expr = {
        m <- mongo(collection = collection_name, 
                   db = "indication", 
                   url = mongoUrl,
                   verbose = TRUE, 
                   options = ssl_options())
        df <- bind_cols(tibble(index = cnt, run_accession = run_id[cnt]), 
                        ena_parse(remDr = remDr, 
                                  ena_url = ena_url, id = run_id[cnt]))
        
        m$insert(df)
        
      },
      error = function(e) {
        re <<- TRUE
      }
    )
    
    if(re){
      print(paste0(run_id[cnt], " re-tried"))
      try(remDr$close())
      remDr$open()
      remDr$navigate(paste0(ena_url, run_id[cnt]))
      Sys.sleep(10)
      
      next
    } else {
      cnt <- cnt + 1
    }
  }
  try(remDr$close())
}

# variable
cores <- 15
cl <- makeCluster(cores)

ena_url <- "https://www.ebi.ac.uk/ena/browser/view/"
mongoUrl <- "mongodb://root:sempre813!@192.168.0.91:27017/admin"
run_id <- read_delim(file = "R-Selenium/head_and_neck.tsv", delim = "\t", col_names = T) %>% pull(1)

# STAR_END

start_end_list <- min_max_chunk(ena_list = length(run_id), cores)

# Cluster define
clusterExport(cl, varlist=c("start_end_list", "ena_parse", "run_parse", "ena_url", "mongoUrl", "run_id"), envir=environment())
clusterEvalQ(cl, {
  library(RSelenium)
  library(tidyverse)
  library(parallel)
  library(mongolite)
})


parLapply(cl = cl,
          X = start_end_list,
          fun = function(se_list) {
            
            print(se_list)
            remDr <- remoteDriver(remoteServerAddr = "localhost",
                                  port = 4444,   # port 번호 입력
                                  browserName = "chrome")
            run_parse(remDr = remDr, ena_url = ena_url, id = run_id, collection_name = "head_neck", start =  se_list[1], end = se_list[2])
          })

# run selenium

