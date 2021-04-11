###############################################################################
##
## Name: 02_data_cleaning.R
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
##                     _i = IoS dataset
##                     _f = furlough dataser
##                     _e = employment dataset
##                     _e_additional = additional employment dataset to calculate pre-cv average
##                     _v = vacancies dataset
##
###############################################################################



## 0. General set up ----------------------------------------------------------



setwd("C:/Users/valeria.rocca/Desktop/MyDocs/TechnicalTest/PartI") 


# Libraries
library(lubridate)
library(tidyverse)
library(dplyr)
library(readxl)
library(xlsx)
library(reshape2)

source("00_functions/00_data_quality_checks.R")

## 1. Read files --------------------------------------------------------------


dataset_cs = read_xlsx("raw_data/card_spending_002021.xlsx", sheet = 2, col_names = FALSE, skip = 4, col_types = "text")[1:6,] 
dataset_i = read_xlsx("raw_data/ios_data_2021-04-10.xlsx", sheet = 1, col_names = T, col_types = "text") 
dataset_f = read_xlsx("raw_data/furlough_data.xlsx", sheet = "3. Time series by sector", col_names = T, col_types = "text")
dataset_e = read_xls("raw_data/employment_data.xls", sheet = 2, col_names = T, col_types = "text") 
dataset_v = read_xls("raw_data/vacancies_data.xls", sheet = 2, col_names = T, col_types = "text") 
dataset_e_additional = read_xls("raw_data/employment_additional.xls", sheet = 2, col_names = T, col_types = "text") 


## 2. Card spending cleaning and quality check ------------------------------------------------------


dataset_cs_clean <- as.data.frame(t(dataset_cs), stringsAsFactors = F)
colnames(dataset_cs_clean) <- dataset_cs_clean[1, ]
dataset_cs_clean <- dataset_cs_clean[-1, ] %>% 
  mutate(`Category` = as.Date(as.numeric(`Category`) , origin = "1899-12-30")) %>% 
  mutate_if(is.character, as.numeric) %>%  # change type of all the other columns
  data.frame() 
colnames(dataset_cs_clean) <- sub("\\.", "_", tolower(colnames(dataset_cs_clean)))
dataset_cs_clean <- dataset_cs_clean %>% 
  dplyr::rename(as_of_date = category) %>% 
  select(-aggregate)

dataset_cs_clean_change <- dataset_cs_clean %>% 
  arrange(as_of_date) %>% 
  mutate(pct_c_delayable = (delayable - lag(delayable))/lag(delayable),
         pct_c_social = (social - lag(social))/lag(social),
         pct_c_staple = (staple - lag(staple))/lag(staple),
         pct_c_work_related = (work_related - lag(work_related))/lag(work_related)) %>% 
  select(as_of_date, pct_c_delayable, pct_c_social, pct_c_staple, pct_c_work_related)

data_checks(dataset_cs_clean_change)

## 3. IoS cleaning ------------------------------------------------------


dataset_i_clean <- dataset_i[-(1:122),] %>% 
  mutate(`as_of_month: Index-1dp` = as.Date(paste(paste0(paste(substr(`Title`, 1, 4), substr(`Title`, 6, 6), sep="-"),tolower(substr(`Title`, 7, nchar(`Title`))),"-01")),format = "%Y-%b-%d") %m+% months(1) - 1) #to make it month end
dataset_i_clean <- dataset_i_clean[,grepl("Index-1dp", names(dataset_i_clean))] %>% 
  select(`as_of_month: Index-1dp`, everything()) %>% 
  filter(`as_of_month: Index-1dp` >= '2020-01-01') 

capital_letters <- toupper(letters)

dataset_i_clean <- dataset_i_clean[substr(colnames(dataset_i_clean), 6, 6) %in% capital_letters | colnames(dataset_i_clean) == c("as_of_month: Index-1dp")]
dataset_i_clean <- dataset_i_clean[substr(colnames(dataset_i_clean), 7, 7) == c(":") | colnames(dataset_i_clean) == c("as_of_month: Index-1dp")]
names_list <- sub("^[^_]*: ","",str_remove(colnames(dataset_i_clean), ": Index-1dp"))
colnames(dataset_i_clean) <- names_list

dataset_i_clean <- dataset_i_clean %>% 
  mutate_if(is.character, as.numeric) %>% 
  as.data.frame() %>% 
  select(as_of_date = as_of_month,
         delayable = `Wholesales, Retail and Motor Trade`,
         social = `Accommodation and food service activities`,
         staple = `Human Health and Social Work Activities`,
         work_related = `Transportation and storage`)

data_checks(dataset_i_clean)


## 4. Furlough cleaning ------------------------------------------------------


dataset_f_clean <- dataset_f[-(1:2),] 
colnames(dataset_f_clean) <- dataset_f_clean[1, ]
dataset_f_clean <- dataset_f_clean[2:(dim(dataset_f_clean)[1]-5),]
dataset_f_clean <- dataset_f_clean %>% 
  mutate(as_of_date = as.Date(as.numeric(`Date`), origin = "1899-12-30")) %>% 
  select(as_of_date, everything()) %>% 
  select(-`Date`, -`Provisional indicator`) %>% 
  mutate_if(is.character, as.numeric) %>% 
  as.data.frame()
colnames(dataset_f_clean) <- sub("\\.", "_", tolower(colnames(dataset_f_clean)))

dataset_f_clean <- dataset_f_clean %>% 
  select(as_of_date,
         delayable = `wholesale and retail; repair of motor vehicles`,
         social = `accommodation and food services`,
         staple = `health and social work`,
         work_related = `transportation and storage`)

dataset_e_additional_clean <- dataset_e_additional[-(1:4),] 
colnames(dataset_e_additional_clean) <- dataset_e_additional_clean[1, ] 
colnames(dataset_e_additional_clean)[1] <- c("as_of_quarter")

dataset_e_additional_clean <- dataset_e_additional_clean[-(1:4),] %>% 
  filter(as_of_quarter == 'Oct-Dec 2019') %>% 
  select(as_of_quarter, 
         delayable = `Wholesale, retail & repair of motor vehicles`,
         social = `Accommod-ation & food services`,
         staple = `Human health & social work activities`,
         work_related = `Transport & storage`) %>% 
  as.data.frame() 

dataset_f_clean <- cbind.data.frame(dataset_f_clean,dataset_e_additional_clean %>% select(-as_of_quarter) %>% 
                                       dplyr::rename(a_delayable = delayable,
                                                     a_social = social,
                                                     a_staple = staple,
                                                     a_work_related = work_related) %>% 
                                       mutate_if(is.character, as.numeric)) %>% 
  mutate(delayable = delayable/a_delayable,
         social = social/a_social,
         staple = staple/ a_staple,
         work_related = work_related/a_work_related) %>% 
  select(as_of_date, delayable, social, staple, work_related)
  
  
data_checks(dataset_f_clean)

## 5. Employment cleaning ------------------------------------------------------


dataset_e_clean <- dataset_e[-(1:8),] 
colnames(dataset_e_clean) <- dataset_e[5, ] 
colnames(dataset_e_clean)[1] <- c("as_of_quarter")
dataset_e_clean <- dataset_e_clean %>% 
  mutate(as_of_quarter = case_when(substr(as_of_quarter,1,7) == "Jan-Mar" ~ paste0(substr(as_of_quarter, 9,12), "-03-31"),
                                   substr(as_of_quarter,1,7) == "Apr-Jun" ~ paste0(substr(as_of_quarter, 9,12), "-06-30"),
                                   substr(as_of_quarter,1,7) == "Jul-Sep" ~ paste0(substr(as_of_quarter, 9,12), "-09-30"),
                                   substr(as_of_quarter,1,7) == "Oct-Dec" ~ paste0(substr(as_of_quarter, 9,12), "-12-31"))) %>% 
  mutate_at(-c(1), as.numeric) %>% 
  filter(as.numeric(substr(as_of_quarter, 1,4)) >= 2019 ) %>% 
  select(as_of_quarter, 
         delayable = `Wholesale, retail & repair of motor vehicles`,
         social = `Accommod-ation & food services`,
         staple = `Human health & social work activities`,
         work_related = `Transport & storage`) %>% 
  as.data.frame() %>% 
  mutate(as_of_quarter = as.Date(as_of_quarter, format = '%Y-%m-%d'))

data_checks(dataset_e_clean)

dataset_e_additional_clean <- dataset_e_additional_clean %>% 
  melt(id = "as_of_quarter") %>% 
  dplyr::rename(average_pre_cv = value) %>% 
  select(variable, average_pre_cv)

## 5. Vacancies cleaning ------------------------------------------------------


dataset_v_clean <- dataset_v[-(1:2),] 
dataset_v_clean <- dataset_v_clean[-(2:5),-2] 
colnames(dataset_v_clean) <- dataset_v_clean[1, ] 
colnames(dataset_v_clean)[1] <- c("as_of_quarter")
dataset_v_clean <- dataset_v_clean[-1,] %>% 
  mutate(as_of_quarter = case_when(substr(as_of_quarter,1,7) == "Jan-Mar" ~ paste0(substr(as_of_quarter, 9,12), "-03-31"),
                                   substr(as_of_quarter,1,7) == "Apr-Jun" ~ paste0(substr(as_of_quarter, 9,12), "-06-30"),
                                   substr(as_of_quarter,1,7) == "Jul-Sep" ~ paste0(substr(as_of_quarter, 9,12), "-09-30"),
                                   substr(as_of_quarter,1,7) == "Oct-Dec" ~ paste0(substr(as_of_quarter, 9,12), "-12-31"))) %>% 
  filter(!is.na(as_of_quarter)) %>% 
  mutate_at(-c(1), as.numeric) %>% 
  filter(as.numeric(substr(as_of_quarter, 1,4)) >= 2019) %>% 
  select(as_of_quarter, 
         delayable = `Wholesale & retail trade; repair of motor vehicles and motor cycles`,
         social = `Accomoda-tion & food service activities`,
         staple = `Human health & social work activities`,
         work_related = `Transport & storage`) %>% 
  as.data.frame() %>% 
  mutate(as_of_quarter = as.Date(as_of_quarter, format = '%Y-%m-%d')) 

data_checks(dataset_v_clean)

## 6. Join the data and check final sample -----------------------------------

dates_list <- seq(as.Date("2020/03/04"), as.Date("2021/03/31"), "days") %>% 
  as.data.frame()

colnames(dates_list)[1] <- c("as_of_date")

dataset_daily <- dates_list %>% 
  left_join(dataset_cs_clean, by = 'as_of_date') %>% 
  left_join(dataset_f_clean, by = 'as_of_date') 

data_checks(dataset_daily)

test_cs <- dates_list %>% 
  left_join(dataset_cs_clean, by = 'as_of_date') %>% 
  filter(is.na(staple)) %>% 
  mutate(week_day = weekdays(as_of_date)) %>% 
  filter(!week_day %in% c('Saturday', 'Sunday')) ## Only 8 non-weekend dates missing, corresponding to bank holidays

test_f <- dates_list %>% 
  left_join(dataset_f_clean, by = 'as_of_date') %>% 
  filter(is.na(staple)) %>% 
  mutate(week_day = weekdays(as_of_date)) ## The missing values in _f dataset are March 2020 and March 2021, due to the fact that the dataset itself starts and ends after/before that

additional_cleaning_cs <- dates_list %>% 
  left_join(dataset_cs_clean, by = 'as_of_date') %>% 
  mutate(prev_del = delayable,
         next_del = delayable,
         prev_stap = staple,
         next_stap = staple,
         prev_soc = social,
         next_soc = social,
         prev_wr = work_related,
         next_wr = work_related) %>% 
  fill(prev_del, .direction = c("up")) %>% 
  fill(next_del, .direction = c("down")) %>% 
  fill(prev_stap, .direction = c("up")) %>% 
  fill(next_stap, .direction = c("down")) %>% 
  fill(prev_soc, .direction = c("up")) %>% 
  fill(next_soc, .direction = c("down")) %>% 
  fill(prev_wr, .direction = c("up")) %>% 
  fill(next_wr, .direction = c("down")) %>% 
  mutate(delayable = ifelse(is.na(delayable), (prev_del + next_del)/2, delayable),
         staple = ifelse(is.na(staple), (prev_stap + next_stap)/2, staple),
         social = ifelse(is.na(social), (prev_soc + next_soc)/2, social),
         work_related = ifelse(is.na(work_related), (prev_wr + next_wr)/2, work_related)) %>% 
  select(as_of_date, delayable, social, staple, work_related)

final_daily_dataset <- additional_cleaning_cs %>% 
  melt(id = 'as_of_date') %>% 
  dplyr::rename(c_value = value) %>% 
  left_join(dataset_i_clean %>% 
              melt(id = 'as_of_date') %>% 
              dplyr::rename(i_value = value), by = c('as_of_date', 'variable')) %>% 
  left_join(dataset_f_clean %>% 
              melt(id = 'as_of_date') %>% 
              dplyr::rename(f_value = value), by = c('as_of_date', 'variable')) %>% 
  left_join(dataset_e_clean %>% 
              melt(id = 'as_of_quarter') %>% 
              dplyr::rename(e_value = value), by = c('as_of_date' = 'as_of_quarter', 'variable')) %>% 
  left_join(dataset_v_clean %>% 
              melt(id = 'as_of_quarter') %>% 
              dplyr::rename(v_value = value), by = c('as_of_date' = 'as_of_quarter' , 'variable')) %>% 
  left_join(dataset_e_additional_clean, by = 'variable')

summary(final_daily_dataset)

## 7. Save data -----------------------------------------------------------------------

write.csv(final_daily_dataset, paste0("final_data/dataset_daily_", Sys.Date(), ".csv"), na = "", row.names = F)
