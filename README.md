# PL/SQL Basics
## Summary
This is a demonstration of basic PL/SQL understanding in stored procedure in addition of basic commands and conditional structures. The project demonstrated dynamic table creation, coupled with data import and data cleaning for further analytics of the data.

## Data Source
1. Data source is from Kaggle - Brazilian E-Commerce Public Dataset by Olist [https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce]
2. 2 files are used in this project ( olist_customers_dataset.csv and olist_geolocation_dataset.csv )

## Initial Setup
1. Oracle VM Virtualbox is used to install the Oracle Database 23ai
2. Script **initialization.sql** is the basic priviledges need to be granted to the user in order for the user to able to access Oracle SQL Developer Web. User requires ORDS schema priviledge in order to access their table in Oracle SQL Developer Web.
3. Granting of priviledge can be done using the default DBA user from Oracle ( e.g. System ).
4. The CSV files can be easily pull into Oracle VM Virtualbox as long it is set as Settings > General > Drag'n'Drop > Bidirectional 

## Script
A total of 3 scripts is created in this project
1. Script **create_table.sql** - Creates new table based on referred dataset. The script will detect the first row as header, and the subsequent row to determine the basic datatype of each individual columns.
2. Script **data_import.sql** - Imports data into the table based on the referred dataset. The script also invoked **create_table.sql** so the new table is auto created before importing new data.
3. Script **geolocation_cleaning.sql** - Cleaning the imported geolocation data for standardization of city names and removing duplicates.

## Limitations
1. Current data source is from CSV file, in scenario whereby the error is due to have multiple values in the Excel cell, separated by comma, the code is currently unable to breakdown to only get the first/last data as desired. Resolving this issue will need to create a temporary table using DataLoader Object, and then perform data cleaning before import into Oracle Database. These steps are currently not within the scope of this project.
2. Currently creation of datatype is based on the 2nd row of the input data. Error might occur if the 2nd row of input data differs from the rest. This can be overcome by having additional code block to check the whole data before starting the table creation. 
