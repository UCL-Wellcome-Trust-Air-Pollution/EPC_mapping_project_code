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
                                   data_uprn_sca_lookup,
                                   geography_var){
  
  # Load UPRN dataset from specified path
  data_uprn_sca_lookup <- data_uprn_sca_lookup %>%
    
    summarise(n_uprn = n(),
              .by = geography_var)
  
  # FIlter most recent EPCs and generate an ID column in the EPC data (to ensure replicability in case
  # of changes to variable names, etc)
  data_epc <- data_epc %>%
    
    filter(most_recent == TRUE) %>%
    
    summarise(n_epc = n(),
              .by = c(geography_var, "rgn22nm"))
  
  # Left join UPRN data to EPC data, group by specified geography, and summarise
  # dataset with percentage of UPRNs in the lookup which exist in the EPC data
  data_coverage <- data_epc %>% 
    
    left_join(data_uprn_sca_lookup, by = geography_var) %>%
    
    # Make variable for the percentage coverage of UPRNs by geography variable
    summarise(coverage_perc = n_epc/n_uprn*100,
              .by = c(geography_var, "rgn22nm"))
  
  # Return dataframe of coverage
  return(data_coverage)
  
}