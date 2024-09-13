# Name of script: PrepareDataToMap
# Description:  Defines function to merge a dataset to a mapping dataset with geometries, ready to map
# and geographical resolution
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 12-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 12-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# Note: For now, the datasets need to have the same resolution (e.g. LA to LA)
# I may change this later to allow for aggregation by level of the mapping dataset

# Define function to merge datasets ready to map -------------------------------

prepare_data_to_map <- function(fill_data,
                                join_var){
  
  # Get fill boundary data using 'join_var'
  fill_boundary_data <- get_mapping_boundaries(join_var)
  
  # Generate merged dataset
  data_to_map <- fill_boundary_data %>%
    
    # Left join to preserve only the rows in the mapping geometries data
    left_join(fill_data, by = join_var)
  
  # Return data ready to map
  return(data_to_map)
  
}