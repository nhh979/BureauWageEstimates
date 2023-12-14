# BureauWageEstimates (In progress)

## Overview
In this project, we will perform data cleaning and data exploring on the Occupational Employment and Wage Statistics (OEWS) data with SQL Server.  
The dataset can be found [here](https://www.bls.gov/oes/current/oes_nat.htm), containing wage estimates for over 800 occupations in all industry sectors, in metropolitan and nonmetropolitan areas, in every state and the District of Columbia.  

## Data Cleaning
Apply some aggregate and window functions as well as CASE WHEN function to clean the data
- Check for number of missing values on some numeric variables and drop those that contains many missing values.
- Drop all the records that simultaneously have missing values in the H_MEAN, H_MEDIAN, A_MEAN, A_MEDIAN columns.
- Impute missing values in the H_MEAN, H_MEDIAN, A_MEAN, A_MEDIAN columns by the calculation anual_wage = hour_wage * 2080.
- Remove duplicated records in the dataset.
- Extract the CITY column from the AREA_TYPE column.

