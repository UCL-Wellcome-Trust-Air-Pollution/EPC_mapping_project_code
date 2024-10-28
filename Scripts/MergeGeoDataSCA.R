# Name of script: MergeGeoDataSCA.R
# Description:  Merges UPRN lookup to SCA areas
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 30-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 30-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------



# Define function to merge SCA data to UPRN lookup -----------------------------

merge_geo_data_sca <- function(geo_data,
                               sca_path_eng,
                               sca_path_wal,
                               long_var,
                               lat_var){
  
  # Read SCA shapefile for England
  sca_data_eng <- read_sf(sca_path_eng) %>%
    
    # Select relevant cols
    select(geometry, type)
  
  # Read SCA data for Wales
  sca_data_wal <- read_sf(sca_path_wal) %>%
    
    # Select geometry column
    select(geometry) %>%
    
    # Generate new 'type' column indicating SCA
    mutate(type = "Smoke Control Area")
  
  # Bind rows together to create final SCA spatial data
  sca_data <- rbind(sca_data_eng,
                    sca_data_wal)
  
  # Create merged geo data frame
  geo_data_sca <- geo_data %>%
    
    # Set as sf object using long/lat variables
    st_as_sf(coords = c(long_var,
                        lat_var),
             remove = FALSE) %>%
    
    # Set CRS to match the SCA shapefile
    st_set_crs(st_crs(sca_data)) %>%
    
    # Left join with SCA shapefile, keeping all rows in UPRN lookup
    st_join(sca_data["type"], left = TRUE) %>%
    
    # Rows not in SCAs show up as NA - convert to 0/1s
    mutate(sca_area = case_when(type == "Smoke Control Area" ~ 1,
                                .default = 0)) %>%
    
    # Remove 'type' column
    select(!type) %>%
    
    # Mutate characters to factors
    mutate(across(where(is.character), as.factor))
  
  # Mutate coordinates to long/lat (CRS 4326) from BNG (CRS 27700) for plotting
  coords_long_lat <- geo_data_sca %>% 
    
    # Transform coordinate reference system
    st_transform(3857) %>%
    
    # Extract coordinate vector
    st_coordinates() %>%
    
    # Set as tibble
    as_tibble() %>%
    
    # Rename to long and lat
    rename(long = X,
           lat = Y)
  
  # Add coordinates to data frame as new columns and remove geometry and old coordinate cols
  geo_data_sca <- geo_data_sca %>%
    
    # Recast as data frame
    as.data.frame() %>%
    
    cbind(coords_long_lat) %>%
    
    select(!c(geometry, long_var, lat_var)) %>%
    
    # Mutate characters to factors
    mutate(across(where(is.character), as.factor))
  
  # Return final data frame
  return(geo_data_sca)
  
}
