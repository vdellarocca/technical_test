###############################################################################
##
## Name: 00_data_quality_checks.R
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
##                     _v = vacancies datset
##
###############################################################################



## 0. General set up ----------------------------------------------------------



setwd("C:/Users/valeria.rocca/Desktop/MyDocs/TechnicalTest/PartI") 


# Libraries
library(lubridate)
library(tidyverse)
library(dplyr)
library(readxl)
library(ggplot2)

## 1. Function definition -----------------------------------------------

data_checks <- function(data_frame_name){
  
  separator_row = c('-') %>% 
    as.data.frame()
  
  #pdf(paste0(data_frame_name, "20210410.pdf")) # To store the histograms in a PDF

  ## Check for outliers
  for(i in 1:length(data_frame_name)){
    
    dft_temp <- data_frame_name %>% 
      mutate(temp_col = data_frame_name[,c(colnames(data_frame_name)[i])])
    
    if(is.numeric(dft_temp$temp_col) == T){
      
      
      print(
        ggplot(dft_temp) +
          aes(x = temp_col) +
          geom_histogram(bins = 20, color="darkblue", fill="lightblue")+
          labs(title = paste("Histogram of", c(colnames(data_frame_name)[i]),collapse = " "),x = c(colnames(data_frame_name)[i]), y = "Count")
      )
      
      
      ggsave(
        paste0("validation_checks/", substr(deparse(substitute(data_frame_name)), 9, 9), "_",substr(c(gsub(" ", "",gsub("[^[:alnum:] ]", "", colnames(data_frame_name)[i]),  fixed = TRUE)), 1, 10), ".jpg"),
        plot = last_plot(),
        dpi = 300,
        limitsize = TRUE,
      )
      
    } else {}
    
    
    temp_var <- summary(data_frame_name[i])
    
    print(temp_var)
    
    write.table(paste0(substr(deparse(substitute(data_frame_name)), 9, 9), "_", c(colnames(data_frame_name)[i])), file = "validation_checks/summary.csv", sep = ":", append = TRUE, quote = FALSE,
                col.names = FALSE, row.names = FALSE)
    write.table(sub(":", ",", temp_var), file = "validation_checks/summary.csv", sep = ":", append = TRUE, quote = FALSE,
                col.names = FALSE, row.names = FALSE)
  }
  
  remove(dft_temp)
  #dev.off()
  
  ## Check for missing values 
  
  print("Missing rate")
  
  for(i in 1:length(data_frame_name)){
    
    dft_temp <- data_frame_name %>% 
      mutate(temp_col = data_frame_name[,c(colnames(data_frame_name)[i])])
    
    missing <- subset(dft_temp,is.na(dft_temp$temp_col))
    missing_rate = round(nrow(missing)/ nrow(dft_temp),digits=4)*100
    print(missing_rate)
  }
  
  ## Check for 0s
  
  print("Zero rate")
  
  for(i in 1:length(data_frame_name)){
    
    dft_temp <- data_frame_name %>% 
      mutate(temp_col = data_frame_name[,c(colnames(data_frame_name)[i])])
    
    zeros = data_frame_name[which(data_frame_name$temp_col==0),]
    zero_rate <- round(nrow(zeros)/nrow(data_frame_name),digits=4)*100
    print(zero_rate)
    
    write.table(zero_rate, file = "validation_checks/summary.csv", sep = ":", append = TRUE, quote = FALSE,
                col.names = FALSE, row.names = FALSE)
    
  }
  
  
  write.table(separator_row, file = "validation_checks/summary.csv", sep = ":", append = TRUE, quote = FALSE,
              col.names = FALSE, row.names = FALSE)
  
}




