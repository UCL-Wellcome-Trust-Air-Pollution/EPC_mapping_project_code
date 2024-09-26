# Name of script: UtilityFunctions
# Description:  Defines set of utility functions which are used in other scripts
# and geographical resolution
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 04-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 04-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------



# Function to get the 'ith' percentile of a dataframe column -------------------

get_percentile <- function(variable, percentile){
  
  percentile <- quantile(variable, percentile, na.rm = TRUE)
  
  return(percentile)
  
}

# Function to download the UK Gov air pollution time series data ---------------

get_air_pollution_data <- function(data_path,
                                   sheet,
                                   data_range,
                                   colnames){
  
  air_pollution_data <- read_ods(here(data_path),
                                sheet = sheet,
                                range = data_range,
                                col_names = colnames) %>%
    
    # Clean names
    clean_names() %>%
    
    # Filter NA (due to issues with spreadsheet formatting)
    filter(if_all(everything(), ~ !is.na(.))) %>%
    
    # Remove aggregated category for 'domestic combustion' - keep wood and non-wood separate
    filter(source != "Domestic Combustion") %>%
    
    # Rename columns to year variable
    rename_with(~ str_sub(., 2, 5), -source) %>%
    
    # Reshape to long format
    pivot_longer(!source,
                 names_to = "year",
                 values_to = "emissions") %>%
    
    # Change to numeric vars
    mutate(year = as.numeric(year))
  
  return(air_pollution_data)
  
}