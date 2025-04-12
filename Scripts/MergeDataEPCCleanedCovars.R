# Name of script: MergeDataEPCCleanedCovars.R
# Description:  Loads statistical geographies and other data to make LSOA-level 
# data to merge with main EPC data
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 03-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 23-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# Loads statistical geography data and merges other data sources
# (e.g. ethnicity, IMD) into LSOA-level lookup dataset 'data_lsoa_lookup'
# I have used full joins to join the LSOA-level data, as at this stage want to 
# keep all data where possible, including missing data
# The resulting dataset is joined to the main EPC data to create a summary LSOA-level
# dataset 

# Define function to merge covars with cleaned main EPC data -------------------

merge_data_epc_cleaned_covars <- function(data,
                                          data_uprn_sca_lookup,
                                          path_stat_geo_files,
                                          path_lsoa_size,
                                          path_imd_eng,
                                          path_imd_wales,
                                          path_lsoa11_lsoa21_lookup,
                                          path_ethnicity,
                                          path_region,
                                          path_ward,
                                          path_urban_rural,
                                          path_age){

  # Merge statistical geographies and SCA areas --------------------------------
  
  # Generate postcode-level lookup data
  data_geo_pcds <- data_uprn_sca_lookup %>%
    
    # Remove missing postcodes
    filter(!is.na(pcds)) %>%
    
    # Drop UPRN column
    select(-uprn) %>%
    
    # Retain distinct rows
    distinct()
  
  # Some postcodes are spread across multiple LSOAs - we exclude these from the
  # analysis since it is not possible to attribute them to a specific LSOA
  # Here we generate a dataset of duplicate postcodes in the lookup, and filter
  # them by performing an anti join with the main postcode lookup dataset
  data_geo_pcds_dupes <- get_dupes(data_geo_pcds, pcds)
  
  data_geo_pcds <- data_geo_pcds %>%
    
    # Anti join to filter postcodes split across multiple LSOAs
    anti_join(data_geo_pcds_dupes)
  
  # Make LSOA-level lookup data ------------------------------------------------
  
  data_lsoa_lookup <- make_lsoa_lookup_data(path_lsoa_size,
                                            path_imd_eng,
                                            path_imd_wales,
                                            path_lsoa11_lsoa21_lookup,
                                            path_ethnicity,
                                            path_region,
                                            path_ward,
                                            path_urban_rural,
                                            path_age)
  
  # Merge statistical geographies and secondary data onto main EPC data --------
  
  # Merge data with UPRNs
  data_epc_cleaned_covars_with_uprn <- data %>%
    
    # Filter non-missing UPRNs
    filter(!is.na(uprn)) %>%
    
    # Keep only distinct rows with UPRNs (we do not do this for those with missing UPRNs
    # since these entries may contain multiple properties with same postcode)
    distinct() %>%
    
    # Left join to statistical geographies by UPRN
    left_join(data_uprn_sca_lookup, by = "uprn") %>%
    
    # Remove Scottish LSOAs
    filter(rgn22cd != "S99999999") %>%
    
    # Full join to LSOA lookup data - full join to keep LSOAs even if no corresponding
    # entries in EPC data
    full_join(data_lsoa_lookup, by = "lsoa21cd")
  
  # Merge data without UPRNs using postcode
  data_epc_cleaned_covars_without_uprn <- data %>%
    
    # Filter only missing UPRNs
    filter(is.na(uprn)) %>%
    
    # Left join to statistical geographies by PCDS
    left_join(data_geo_pcds, by = c("postcode" = "pcds")) %>%
    
    # Remove Scottish LSOAs
    filter(rgn22cd != "S99999999") %>%
    
    # Left join to LSOA lookup data (only keep rows in main EPC data)
    left_join(data_lsoa_lookup, by = "lsoa21cd") %>%
    
    # Create 'most recent' variable (assume all EPCs without UPRN are most recent)
    mutate(most_recent = TRUE)
  
  # Set to data.table
  setDT(data_epc_cleaned_covars_with_uprn)
        
  # Generate new indicator variable for whether an EPC is the most recent 
  # for that UPRN. NOTE: the rows are pre-ordered by date in the 'CleanDataEPC' script
  data_epc_cleaned_covars_with_uprn <- data_epc_cleaned_covars_with_uprn[, most_recent := rowid(uprn) == 1]
  
  # Note: In the case of missing UPRNs, I keep all observations since we cannot
  # tell whether there are duplicate EPCs or not
  
  # Merge two data.tables to recreate main data.table
  data_epc_cleaned_covars <- bind_rows(data_epc_cleaned_covars_with_uprn,
                                       data_epc_cleaned_covars_without_uprn) %>%
    
    # Remove duplicate columns
    select(!ends_with(".y")) %>%
    
    rename_with(~ str_replace(., ".x", "")) %>%
    
    # Create indicator for EPC number by property (inverse of row_number() function)
    # and for total number of EPCs by property
    mutate(total_epc = max(row_number()),
           epc_number = total_epc - row_number() + 1,
           .by = uprn) %>%
    
    # Create new binary variable for urban/rural
    mutate(urban = case_when(grepl("Urban", ruc11) ~ 1,
                             grepl("Rural", ruc11) ~ 0,
                             .default = NA)) %>%
    
    # Remove unused variables
    select(!c(postcode,
              inspection_date,
              pcds, 
              ruc11)) %>%
    
    # Set character variables as factors
    mutate(across(where(is.character), as.factor))
  
  # Test remove ancilliary datasets
  rm(data_uprn_sca_lookup,
     data_epc_cleaned_covars_with_uprn,
     data_epc_cleaned_covars_without_uprn,
     data_geo_pcds,
     data_geo_pcds_dupes)
  
  # Return 'data_epc_cleaned_covars'
  return(data_epc_cleaned_covars)

}