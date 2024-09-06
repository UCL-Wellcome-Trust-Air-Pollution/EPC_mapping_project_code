# Name of script: X_UtilityFunctions
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