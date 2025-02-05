# Name of script: run.R
# Description: Master script to run pipeline in '_targets.R' script
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 20-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 11-12-2024

# Notes ------------------------------------------------------------------------

# This file merges EPC data from raw (unzipped) files and then runs the analysis pipeline
# If data is already detected in the output directory, the 'get_epc_data' function will prompt
# if you want to rerun the function. If the output directory has changed, the script will be rerun.
# Once you have run the 'get_epc_data' function once, you may want to delete the initial (unzipped)
# EPC data folders, as the file size is very large. 

# Set path to unzipped EPC data and directory for output data ------------------

# Restore packages
renv::restore()

library(here)
library(future)
library(fs)
library(dplyr)
library(furrr)
library(vroom)
library(arrow)

# Update this path with the path to the unzipped EPC data on your local device (note: the path only needs to be specified from the R Project directory)
path_data_epc_folders <- here("Data/raw/epc_data/epc_data_extracted")

# Set output directory (this should be within the 'Data' subfolder)
output_dir <- ("Data/raw/epc_data")

# Collect EPC data from unzipped folders ---------------------------------------

# Source merging function
source(here("Scripts/GetEPCData.R"))

# Run merging function to send data to specified output directory (defaults to "Data/raw/epc_data/data_epc_raw.parquet)
# NOTE: If you want to change the output directory ('output_dir') then you will need to change the first argument of 
# function 'clean_data_epc' to match this output directory

get_epc_data(path_data_epc_folders = here(path_data_epc_folders), 
             epc_cols_to_select = c("UPRN", "SECONDHEAT_DESCRIPTION", "MAINHEAT_DESCRIPTION",
                                                    "INSPECTION_DATE", "CONSTRUCTION_AGE_BAND", "PROPERTY_TYPE",
                                                    "BUILT_FORM", "TENURE", "POSTCODE"), 
             output_dir = output_dir)

# Remove folder of unzipped EPC data 
unlink(path_data_epc_folders, recursive = TRUE)

# Run pipeline -----------------------------------------------------------------

targets::tar_make()
