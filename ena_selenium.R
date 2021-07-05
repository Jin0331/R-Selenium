library(RSelenium)
library(tidyverse)


run_id <- read_delim(file = "ena_sra-run_20210705-0207.tsv", delim = "\t", col_names = T) %>% 
  pull(1)
ena_url <- "https://www.ebi.ac.uk/ena/browser/view/"
ena_parse <- function(remDr, ena_url, id, sleep_cnt = 3){
  
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

# run selenium
remDr <- remoteDriver(remoteServerAddr = "localhost" ,
                      port = 4444,   # port 번호 입력
                      browserName = "chrome")  
remDr$open()


# run
result_list <- list()
cnt <- 1
while(cnt <= length(run_id)){
  print(run_id[cnt])
  re <- FALSE
  tryCatch(
    expr = {
    result_list[[cnt]] <- ena_parse(remDr = remDr, 
                                   ena_url = ena_url,
                                   id = run_id[cnt])
    },
    error = function(e) {
      re <<- TRUE
    }
  )
  
  if(re){
    print(paste0(run_id[cnt], " re-tried"))
    next
  } else {
    cnt <- cnt + 1
    Sys.sleep(2)
  }
  
  
}

result_list %>% bind_rows() %>% View()



