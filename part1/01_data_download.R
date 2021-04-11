###############################################################################
##
## Name: 01_data_download.R
## Purpose: 
## Author: VDR
## Email: valeria.dellarocca@fundingcircle.com
## Date: 2021-04-09
## Version: v1
##
###############################################################################
##
## Notes: Code for the Technical Test - Part I: Exploratory Data Analysis
##        This code is to download the different datasets
##        Conventions: _cs = card spending dataset
##                    _i = IoS dataset
##
###############################################################################



## 0. General set up ----------------------------------------------------------



setwd("C:/Users/valeria.rocca/Desktop/MyDocs/TechnicalTest/PartI") 


# Libraries
library(lubridate)
library(tidyverse)
library(dplyr)



# 0.1 Choice of the data sources =======================================================================



url_name_list = c("https://www.ons.gov.uk/economy/economicoutputandproductivity/output/datasets/ukspendingoncreditanddebitcards/",
                  "https://www.ons.gov.uk/economy/economicoutputandproductivity/output/datasets/indexofservices/current/",
                  "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/972000/CJRS_Statistics_March_2021_-_data_tables.xlsx",
                  "https://www.ons.gov.uk/file?uri=/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/datasets/employmentbyindustryemp13/current/emp13nsafeb2021.xls",
                  "https://www.ons.gov.uk/file?uri=/employmentandlabourmarket/peoplenotinwork/unemployment/datasets/vacanciesbyindustryvacs02/current/vacs02mar2021.xls",
                  "https://www.ons.gov.uk/file?uri=/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/datasets/employmentbyindustryemp13/current/emp13nsafeb2021.xls")


## 1. Card spending dataset ----------------------------------------------------------

{

  ## We will genralise the download url of this dataset in order 
  ## for it to self-adjust for any time there is a new dataset
  
  url_read_cs <- readLines(url_name_list[1])
  general_url_name_cs <- paste0(url_name_list[1], sub("^.*ukspendingoncreditanddebitcards/", "", url_read_cs))
  subset_files_cs <- general_url_name_cs[grep("\\.xlsx", general_url_name_cs)] 
  subset_files_clean_cs <- gsub("(?<=\\.xlsx).*", "", subset_files_cs, perl=TRUE)
  subset_files_clean_cs2 <- gsub("https://www.ons.gov.uk/", "https://www.ons.gov.uk/file?uri=/", subset_files_clean_cs) 
  subset_files_clean_cs2 <- subset_files_clean_cs2[!grepl("/v",subset_files_clean_cs2)]
  
  
  ## We want to generalise the name of the output too
  ## for it to self-adjust to the latest updated date of the dataset
  
  name_temp_cs <- sub('.*/', '', subset_files_clean_cs2)
  file_name_aux_cs1 = gsub(".*(2021//)", "", gsub("(?<=ukspendingoncreditanddebitcardsdataset).*", "", subset_files_clean_cs2,perl=TRUE))
  file_name_aux_cs = str_pad(as.numeric(sub(".*?([0-9]+).*", "\\1", file_name_aux_cs1)), 6, pad = "0")
  file_name_cs = paste0("raw_data/card_spending_", file_name_aux_cs , ".xlsx")
  
  
  download.file(subset_files_clean_cs2[1], file_name_cs,  mode = "wb")

}

## 2. IoS dataset ----------------------------------------------------------

{
  
  url_read_i <- readLines(url_name_list[2])
  general_url_name_i <- paste0(url_name_list[2], sub("^.*current", "", url_read_i))
  subset_files_i <- general_url_name_i[grep("\\.xlsx", pg_b)] 
  subset_files_clean_i <- gsub("(?<=\\.xlsx).*", "", subset_files_i, perl=TRUE)
  subset_files_clean_i <- gsub("https://www.ons.gov.uk/", "https://www.ons.gov.uk/file?uri=/", subset_files_clean_i) 
  subset_files_clean_i <- subset_files_clean_i[!grepl("/v",subset_files_clean_i)]
  name_temp_i <- sub('.*/', '', subset_files_clean_i)
  file_name_i = paste0("raw_data/ios_data_", Sys.Date(), ".xlsx")
  download.file(subset_files_clean_i[1], file_name_i, mode = "wb")
  
}


## 3. UK Gov Furlough, Employment, and Vacancies dataset ---------------------------
{
  
  file_name_list = c("furlough_data", "employment_data", "vacancies_data", "employment_additional")
  
  for(i in 3:6){
    
    if(i == 3) {file_extension = ".xlsx" } else {file_extension = ".xls"}
     
    download.file(url_name_list[i], paste0("raw_data/", as.character(file_name_list[i-2]), file_extension), mode = "wb")
  
    }
}


