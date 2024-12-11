# Name of script: run.R
# Description: Master script to run pipeline in '_targets.R' script
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 20-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 27-09-2024

# Notes ------------------------------------------------------------------------

# This file merges EPC data from raw (unzipped) files and then runs the analysis pipeline
# If data is already detected in the output directory, the 'get_epc_data' function will prompt
# if you want to rerun the function. If the output directory has changed, the script will be rerun.
# Once you have run the 'get_epc_data' function once, you may want to delete the initial (unzipped)
# EPC data folders, as the file size is very large. 

# Collect EPC data from unzipped folders ---------------------------------------
library(here)

# Source merging function
source(here("Scripts/GetEPCData.R"))

# Run merging function to send data to specified output directory (defaults to "Data/raw/epc_data/data_epc_raw.parquet)
# NOTE: If you want to change the output directory ('output_dir') then you will need to change the first argument of 
# function 'clean_data_epc' to match this output directory

get_epc_data(path_data_epc_folders = here("epc_data/epc_data_extracted"), 
             epc_cols_to_select = c("UPRN", "SECONDHEAT_DESCRIPTION", "MAINHEAT_DESCRIPTION",
                                                    "INSPECTION_DATE", "CONSTRUCTION_AGE_BAND", "PROPERTY_TYPE",
                                                    "BUILT_FORM", "TENURE", "POSTCODE"), 
             output_dir = "Data/raw/epc_data")

# Run pipeline -----------------------------------------------------------------

# Uncomment to run sequentially without parallelisation
#targets::tar_make()

# Uncomment to run targets in parallel on your local machine (specify number of workers)

# Set future options to support up to 5Gb of global variables
options(future.globals.maxSize = 5000 * 1024^2)

targets::tar_make_future(workers = 4)

# Uncomment to run targets in parallel
# on local processes or a Sun Grid Engine cluster.
# targets::tar_make_clustermq(workers = 2L)