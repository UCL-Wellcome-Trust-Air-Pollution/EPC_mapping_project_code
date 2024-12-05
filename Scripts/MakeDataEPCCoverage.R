# Name of script: MergeStatisticalGeographies
# Description:  Defines function to generate a dataset of the percentage of 
# properties in the ONS UPRN lookup included in the main EPC data, by 
# an arbitrary statistical geography
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 13-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 13-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------



# Define function to generate dataset of EPC coverage by geography -------------

make_data_epc_coverage <- function(data_epc,
                                   data_os,
                                   data_uprn_sca_lookup,
                                   group_var,
                                   path_lsoa_size,
                                   path_imd_eng,
                                   path_imd_wales,
                                   path_lsoa11_lsoa21_lookup,
                                   path_ethnicity,
                                   path_region,
                                   path_ward,
                                   path_urban_rural,
                                   path_age){
  
  # Make LSOA lookup data
  data_lsoa_lookup <- make_lsoa_lookup_data(path_lsoa_size,
                                            path_imd_eng,
                                            path_imd_wales,
                                            path_lsoa11_lsoa21_lookup,
                                            path_ethnicity,
                                            path_region,
                                            path_ward,
                                            path_urban_rural,
                                            path_age)
  
  # Load OS AddressBase dataset from specified path
  data_os_uprn <- data_os %>%
  
  # Left join OS data to statistical geographies
    left_join(data_uprn_sca_lookup, by = "uprn") %>%
    
    # Filter non-matched UPRNs (exclude if cannot be linked to a statistical geography)
    # and Scottish LSOAs
    filter(!is.na(lsoa21cd) & str_sub(lsoa21cd, 1, 1) != "S")
  
  # Keep distinct UPRNs in EPC data
  data_epc <- data_epc %>%
    
    distinct(uprn, .keep_all = TRUE) %>%
    
    # Make indicator variable for existence of EPC
    mutate(epc_exists = 1) %>%
    
    # Select relevant cols
    select(uprn, 
           epc_exists)
  
  # Left join UPRN lookup to EPC data
  data_epc_coverage <- data_os_uprn %>% 
    
    # Left join OS data to EPC data by UPRN
    left_join(data_epc, by = "uprn") %>%
    
    # Set 'epc_exists' to 0 if NA
    mutate(epc_exists = case_when(is.na(epc_exists) ~ 0,
                                  .default = epc_exists)) %>%
    
    # Summarise coverage by geography variable
    summarise(epc_coverage = mean(epc_exists, na.rm = TRUE) * 100,
              .by = {{group_var}}) %>%
  
  # Merge to LSOA lookup data
  left_join(data_lsoa_lookup, by = "lsoa21cd")
  
  return(data_epc_coverage)
  
}
