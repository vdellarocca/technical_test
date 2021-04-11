# technical_test - Part 1


Codes description


The codes used in part 1 are divided as follows:
1.	01_ data_download.R download and saves the raw Excel files from a website
2.	02_data_aggregation.R read the downloaded files, and cleans them:

Note that the majority of the cleaning is done with a function (located in TechnicalTest/PartI/00_functions/00_data_quality_checks.R). This is to avoid making the code repetitive and complicated to read.

I will now explain each code in a bit more detail.

1.	00_data_quality_checks.R

This is the function used to perform the data quality checks.
The first thing it does is to create an histogram of the variable. The purpose is twofold:
1.	Graphically check for outliers
2.	Graphically check for unusual concentrations in specific bins.
 
Each plot is then saved as jpg file in a specific folder (see /TechnicalTest/PartI/validation_checks).
 
A more compact way would be to save everything in a single pdf file, which is recommended in case of many variables. However, here I don’t really have that need, given the limited number of fields, and jpgs are very immediate to use in ppt.
This process of plotting and saving is for numerical columns only.
 
The next step is to create a summary of the key metrics of the variable, e.g. min/max. The summary is then saved in a summary.csv file. 
 
For each variable, one should expect in the csv the first row with the name of the variable, and the next few rows with the summary. 
 
This is all embedded in a for loop, to iterate it on all the fields of a certain dataframe. Once it has looked on all the variables of a data frame, the code also adds a “-“ to the csv, to separate it to the output of the next dataframe.
Lines 89 to 99 are dedicated to the calculation of the missing rate, whilst lines 103-117 to that of the 0 rate (sometimes 0 values are used by bureaus for specific purposes, or to fill in missing values).
If one calls in a code data_checks(dataframe_name) then, after it has run, they should have the summary csv and all the histograms in the validation folder.

2.	01_ data_download.R

After loading the needed packages and setting the working directory, I define the list of URL of the files I want to download.
 
The first URL allows for an intuitive generalisation. I have tried to generalise both the URL and the output file name, so that if in the future one may want to download a newer version of the file, they won’t need to find the new URL (assuming that the website keeps the same format for their URL). Besides that, lines 54-71 check all the links at that URL, select only the .xlsx ones, and removes the previous versions of the file (which are also available for download, so a search of the .xlsx would download those too), selecting only the latest one.
 
The part that download the next dataset if similar to the first one, whilst for datasets 3 to 6 I have taken directly the URL of the xlsx/xls files and simply download them.
 
A simpler approach would be to go directly to each website and manually download the files.

3.	02_data_aggregation.R

The majority of the code is dedicated to formatting the files we have downloaded with code 01. 
The first part of the code reads the files, then for each individual file it manipulates the data frames columns and types. It also only selects the fields we are interested in (that is, a reference date, and the sectors we want to analyse). This code also does some variable transformation, when needed. Please refer to the ppt to see the various output.
Note that also the variable definition part could be accomplished with a function. However, the name of each field was different from one dataset to the other, so the function may end up be as long as doing this individually for each dataset. 
data_checks(dataframe_name) is the function that performs the data cleaning, which was explained in Sect 1.
The final part of the code (line 185 onward) creates a sequence of dates and use that as a base to join the various dataframes:
 
The reason for this is that, whilst our checks have not highlighted any missing values, one could potentially have some rows entirely missing. So there it was no row for some dates, which would still pass our data validation checks, but may have an impact on the analysis. We have then re-checked the missing values of the dataframe aggregated in this way, and this happened to be the case. We have then proceeded to investigate why two dataframes had missing values. The result is as follows:
•	Card spending data: the missing values were related to weekends and bank holidays. In this case, I have mitigated it by imputing the missing to the average between the previous and the next non missing value. The rational is that there may indeed be some variation in credit card spending over weekends (or on the day of a bank holiday), but this would likely be cyclicality, whilst we are more interested in macro trends. Hence, a smoothing shouldn’t represent a problem
•	Furlough data: the missing dates were due to the different range of the reports provided (furlough data start from 23 March 2020 and end on 28 February 2021)

