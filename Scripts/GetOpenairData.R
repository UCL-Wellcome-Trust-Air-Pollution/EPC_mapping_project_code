# Name of script: GetOpenairData
# Description:  Defines function to generate dataset from R package openair
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 31-10-2024
# Latest update by: Calum Kennedy
# Latest update on: 31-10-2024
# Update notes: 

# Comments ---------------------------------------------------------------------



# Define function to get openair data ------------------------------------------

get_openair_data <- function(source_list,
                             year_list,
                             frequency = "hourly",
                             pollutant_list = "all"){
  
  # Get vector of site codes to pass to 'importUKAQ'
  sites <- importMeta(source = source_list,
                      all = TRUE) %>%
    
    # Filter out Scottish/Irish monitoring stations
    filter(!str_detect(zone, paste0(c("Ireland", "Scotland"), collapse = "|"))) %>%
    
    # Keep distinct codes
    distinct(code)
  
  # Get openair data
  openair_data <- importUKAQ(site = sites$code,
                             year = year_list,
                             data_type = frequency,
                             pollutant = pollutant_list,
                             meta = TRUE) %>%
    
    # Create new variable for day of week and month
    mutate(day = weekdays(date),
           month = lubridate::month(date))
  
  # If frequency is 'hourly' - create new column called 'hour' for hour of day
  if(frequency == "hourly") openair_data <- openair_data %>% mutate(hour = format(date, "%H"))
  
  return(openair_data)

} 
