# Name of script: SetSpatialPoints
# Description:  Defines function to link spatial monitor data to WF location data
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 31-10-2024
# Latest update by: Calum Kennedy
# Latest update on: 31-10-2024
# Update notes: 

# Comments ---------------------------------------------------------------------



# Define function to set dataset to spatial points -----------------------------

set_spatial_points <- function(data,
                                 longitude_var,
                                 latitude_var){
  
  sf_data <- data %>%
    
    # Set as sf object
    st_as_sf(coords = c(longitude_var,
                        latitude_var)) %>%
    
    # Set default CRS
    st_set_crs(4326) %>%
    
    # Transform CRS
    st_transform(27700)
  
  # Return prepared sf
  return(sf_data)
  
}

