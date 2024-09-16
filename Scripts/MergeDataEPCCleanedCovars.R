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
                                          path_ward,
                                          path_sca_data,
                                          filter_most_recent_epc){

  # Merge statistical geographies ----------------------------------------------
  
  data_geo_uprn <- merge_statistical_geographies(path_stat_geo_files)
  
  # Generate postcode-level lookup data
  data_geo_pcds <- data_geo_uprn %>%
    
    # Drop UPRN column
    select(-uprn) %>%
    
    # Remove duplicate rows
    distinct()
  
  # Make LSOA-level lookup data ------------------------------------------------
  
  data_lsoa_lookup <- make_lsoa_lookup_data(path_lsoa_size,
                                            path_imd_eng,
                                            path_imd_wales,
                                            path_ethnicity,
                                            path_region,
                                            path_ward)
  
  # Load smoke control data ----------------------------------------------------
  
  sca_data <- vroom(path_sca_data) %>%
    
    # Mutate NA to 0 (i.e. UPRN is not in a smoke control area)
    mutate(smoke_ctrl = case_when(is.na(smoke_ctrl) ~ 0,
                                  .default = smoke_ctrl)) %>%
    
    # Keep only relevant variables
    select(uprn, smoke_ctrl)
  
  # Merge statistical geographies and secondary data onto main EPC data --------
  
  # Merge data with UPRNs
  data_epc_cleaned_covars_with_uprn <- data %>%
    
    # Filter non-missing UPRNs
    filter(!is.na(uprn)) %>%
    
    # Left join to statistical geographies by UPRN
    left_join(data_geo_uprn, by = "uprn") %>%
    
    # Remove Scottish LSOAs
    filter(rgn22cd != "S99999999") %>%
    
    # Full join to merged data on IMD, ethnicity, etc
    full_join(data_lsoa_lookup, by = "lsoa21cd") %>%
    
    # Remove duplicate cols
    select(!ends_with(".y")) %>%
    
    rename_with(~str_replace(., ".x", ""), ends_with(".x"))
  
  # Merge data without UPRNs using postcode
  data_epc_cleaned_covars_without_uprn <- data %>%
    
    # Filter only missing UPRNs
    filter(is.na(uprn)) %>%
    
    # Left join to statistical geographies by PCDS
    left_join(data_geo_pcds, by = c("postcode" = "pcds")) %>%
    
    # Remove Scottish LSOAs
    filter(rgn22cd != "S99999999") %>%
    
    # Full join to merged data on IMD, ethnicity, etc
    full_join(data_lsoa_lookup, by = "lsoa21cd") %>%
    
    # Remove duplicate cols
    select(!ends_with(".y")) %>%
    
    rename_with(~str_replace(., ".x", ""), ends_with(".x"))
  
  # Set to data.table (faster for operations below)
  setDT(data_epc_cleaned_covars_with_uprn)
  setDT(data_epc_cleaned_covars_without_uprn)
  
  # Ensure inspection_date is in Date format
  data_epc_cleaned_covars_with_uprn[, inspection_date := as.Date(fast_strptime(inspection_date, format = "%Y-%m-%d"))]
  data_epc_cleaned_covars_without_uprn[, inspection_date := as.Date(fast_strptime(inspection_date, format = "%Y-%m-%d"))]

  # Order data by descending inspection date
  setorder(data_epc_cleaned_covars_with_uprn, -inspection_date)
  
  # Filter only most recent EPC 
  if(filter_most_recent_epc == TRUE) data_epc_cleaned_covars_with_uprn <- unique(data_epc_cleaned_covars_with_uprn, by = "uprn")
  
  # Merge two data.tables to create main data.table
  data_epc_cleaned_covars <- bind_rows(data_epc_cleaned_covars_with_uprn,
                                       data_epc_cleaned_covars_without_uprn)
  
  # Retain only unique values in final data
  data_epc_cleaned_covars <- unique(data_epc_cleaned_covars)
  
  # Merge final data to smoke control areas using UPRN
  data_epc_cleaned_covars <- data_epc_cleaned_covars %>%
    
    # Retain all rows in main data (left join)
    left_join(sca_data, by = "uprn")
  
  # Return 'data_epc_cleaned_covars'
  return(data_epc_cleaned_covars)

}
