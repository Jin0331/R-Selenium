library(RSelenium)
library(tidyverse)
library(mongolite)

mongoUrl <- "mongodb://root:sempre813!@192.168.0.91:27017/admin"
pan <- mongo(collection = "pancreatic", 
             db = "indication", 
             url = mongoUrl,
             verbose = TRUE, 
             options = ssl_options())

# function
run_parse <- function(remDr, ena_url, id, collection_name){
  ena_parse <- function(remDr, ena_url, id, sleep_cnt = 2.5){
    
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
  remDr$open() 
  cnt <- 1
  while(cnt <= length(run_id)){
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
      
      next
    } else {
      cnt <- cnt + 1
    }
  }
}

# Selenium server
remDr <- remoteDriver(remoteServerAddr = "localhost",
                      port = 4444,   # port 번호 입력
                      browserName = "chrome")  
run_id <- read_delim(file = "R-Selenium/cololectal.tsv", delim = "\t", col_names = T) %>% pull(1)
ena_url <- "https://www.ebi.ac.uk/ena/browser/view/"


# run selenium
run_parse(remDr = remDr, ena_url = ena_url, id = run_id, collection_name = "colon")


# run

result_list %>% bind_rows() %>% 
  bind_cols(RUN_ID = run_id, .) %>% 
  write_delim(file = "pancreatic_ena_list.txt", delim = "\t")
