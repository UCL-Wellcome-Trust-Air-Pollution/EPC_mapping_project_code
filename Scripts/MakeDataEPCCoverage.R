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
                                   path_stat_geo_files,
                                   geography){
  
  # Load UPRN dataset from specified path
  data_geo <- merge_statistical_geographies(path_stat_geo_files)
  
  # Generate an ID column in the EPC data (to ensure replicability in case
  # of changes to variable names, etc)
  data_epc <- data_epc %>%
    
    mutate(id = 1)
  
  # Left join UPRN data to EPC data, group by specified geography, and summarise
  # dataset with percentage of UPRNs in the lookup which exist in the EPC data
  data_coverage <- data_geo %>% 
    
    left_join(data_epc, by = "uprn") %>%
    
    # Remove duplicate cols
    select(!ends_with(".y")) %>%
    
    rename_with(~str_replace(., ".x", ""), ends_with(".x")) %>%
    
    summarise(coverage_perc = sum(!is.na(id))/n()*100,
              .by = {{geography}})
  
  # Return dataframe of coverage
  return(data_coverage)
  
}
