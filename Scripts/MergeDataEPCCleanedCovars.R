# Name of script: 2a_MakeLSOAData.R
# Description:  Loads statistical geographies and other data to make LSOA-level 
# data to merge with main EPC data
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 03-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 03-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# Loads statistical geography data and merges other data sources
# (e.g. ethnicity, IMD) into LSOA-level lookup dataset 'data_lsoa_lookup'
# I have used full joins to join the LSOA-level data, as at this stage want to 
# keep all data where possible, including missing data
# The resulting dataset is joined to the main EPC data to create a summary LSOA-level
# dataset in the '2b_MergeLSOAData_EPC.R' script

# Define function to merge covars with cleaned main EPC data -------------------

merge_data_epc_cleaned_covars <- function(data,
                                          path_stat_geo_files,
                                          path_lsoa_size,
                                          path_imd_eng,
                                          path_imd_wales,
                                          path_ethnicity,
                                          path_region,
                                          path_ward){

  # Merge statistical geographies ----------------------------------------------
  
  data_geo <- merge_statistical_geographies(path_stat_geo_files)
  
  # Make LSOA-level lookup data ------------------------------------------------
  
  data_lsoa_lookup <- make_lsoa_lookup_data(path_lsoa_size,
                                            path_imd_eng,
                                            path_imd_wales,
                                            path_ethnicity,
                                            path_region,
                                            path_ward)
  
  # Merge statistical geographies and secondary data onto main EPC data --------
  
  data_epc_cleaned_covars <- data %>%
    
    # Left join to statistical geographies by UPRN
    left_join(data_geo, by = "uprn") %>%
    
    # Remove Scottish LSOAs
    filter(rgn22cd != "S99999999") %>%
    
    # Full join to merged data on IMD, ethnicity, etc
    full_join(data_lsoa_lookup, by = "lsoa21cd") %>%
    
    # Remove duplicate cols
    select(!ends_with(".y")) %>%
    
    rename_with(~str_replace(., ".x", ""), ends_with(".x"))
  
  # Set to data.table (faster for operations below)
  setDT(data_epc_cleaned_covars)
  
  # Ensure inspection_date is in Date format
  data_epc_cleaned_covars[, inspection_date := as.IDate(inspection_date, format = "%Y-%m-%d")]
  
  # Calculate the most recent date per UPRN and flag the most recent entry
  data_epc_cleaned_covars[, most_recent := as.integer(inspection_date == max(inspection_date)), by = uprn]
  
  # Return 'data_epc_cleaned_covars'
  return(data_epc_cleaned_covars)

}
