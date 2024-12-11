# Name of script: MakeLAEIData
# Description: Defines function to make merged grid square LAEI data for mapping
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 30-11-2024
# Latest update by: Calum Kennedy
# Latest update on: 30-11-2024

# Comments ---------------------------------------------------------------------



# Define function to make summary data by group --------------------------------

make_laei_data <- function(path_data_laei,
                           data_os,
                           data_uprn_sca_lookup,
                           data_epc_cleaned_covars){
  
  # Get LAEI shapefile
  shp_laei <- read_sf(path_data_laei) %>%
    
    # Clean names
    clean_names() %>%
    
    # Keep GLA authorities
    filter(borough != "Non GLA") %>%
     
    # Select column for domestic biomass emissions in 2019
    select(biomass19, grid_id) %>%
    
    # Set crs to match EPC data
    st_transform(3857)
  
  # Keep relevant rows from UPRN lookup
  data_uprn_sca_lookup <- data_uprn_sca_lookup %>%
    
    select(uprn,
           rgn22cd,
           long,
           lat) %>%
    
    # Filter London UPRNs
    filter(rgn22cd == "E12000007")
  
  # Process EPC data
  data_epc_cleaned_covars_wood <- data_epc_cleaned_covars %>%
    
    # Remove non WF heat sources
    filter(most_recent == TRUE) %>%
    
    # Select relevant cols
    select(any_wood, uprn)
  
  # Merge OS, UPRN, and EPC data
  data_os_uprn_epc <- data_os %>%
    
    # Left join to UPRN data 
    left_join(data_uprn_sca_lookup, by = "uprn") %>%
    
    # Retain London UPRNs
    filter(rgn22cd == "E12000007") %>%
    
    # Remove region col
    select(!rgn22cd) %>%
    
    # Left join to EPC data
    left_join(data_epc_cleaned_covars_wood, by = "uprn") %>%
    
    # Filter if missing coordinates and if census property type missing 
    filter(!is.na(long) & !is.na(lat) & !is.na(property_type_census)) %>%
    
    # Set as sf
    st_as_sf(coords = c("long",
                        "lat")) %>%
    
    # Transform crs for consistency with LAEI shapefile
    st_set_crs(3857)
  
  # Merge shapefile with OS, UPRN and EPC lookup and generate summary variables
  shp_laei_merged <- shp_laei %>%
    
    # st join to OS, UPRN, EPC data by st_contains
    st_join(data_os_uprn_epc, join = st_contains) %>%
    
    # Group by grid square ID and Census property type
    group_by(grid_id,
             property_type_census) %>%
    
    # Get total N properties from OS data by grid square and property type,
    # Percentage of properties with WF by grid square and property type,
    # and retain PM2.5 emissions for later mapping
    summarise(n_properties = n(),
              n_epc = sum(!is.na(any_wood), na.rm = TRUE),
              wf_perc = mean(any_wood, na.rm = TRUE),
              pm_25_emissions = mean(biomass19, na.rm = TRUE)) %>%
    
    # Ungroup 
    ungroup() %>%
    
    # Calculate total predicted WF heat sources by property type as product of 
    # n_properties and WF percentage
    mutate(n_wood_pred = n_properties * wf_perc) %>%
    
    # Group by grid ID
    group_by(grid_id) %>%
    
    # Get total sum of predicted WF heat sources and mean PM2.5 emissions by grid square
    summarise(n_wood_pred = sum(n_wood_pred, na.rm = TRUE),
              pm_25_emissions = mean(pm_25_emissions, na.rm = TRUE))
  
  # Return merged shapefile
  return(shp_laei_merged)
  
}
