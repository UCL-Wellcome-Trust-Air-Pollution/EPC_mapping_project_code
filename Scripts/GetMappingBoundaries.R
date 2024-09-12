# Name of script: GetMappingBoundaries
# Description:  Function to load geographic boundary shapefiles for choropleth maps
# and geographical resolution
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 03-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 03-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# Function to load geographical boundaries for use in mapping

# Define function to load geographical boundaries ------------------------------

get_mapping_boundaries <- function(geography_var){
  
  if(geography_var == "lsoa21cd") GeoJSON_url <- "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Lower_layer_Super_Output_Areas_2021_EW_BGC_V3/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson"
      
  if(geography_var == "wd22cd") GeoJSON_url <- "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Wards_December_2022_Boundaries_GB_BGC/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson"
          
  if(geography_var == "lad22cd") GeoJSON_url <- "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_December_2022_UK_BGC_V2/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson"
  
  # Download JSON file from url
  json <- read_sf(GeoJSON_url) %>%
    
    # Clean names with janitor package
    clean_names() %>%
    
    # Make geometry valid
    st_make_valid()
  
  # Filter out Scottish regions by geography variable
  if(geography_var == "lsoa21cd") json_filtered <- json %>% filter(!str_sub(lsoa21cd, 1, 1) %in% c("S", "N"))
  if(geography_var == "wd22cd") json_filtered <- json %>% filter(!str_sub(wd22cd, 1, 1) %in% c("S", "N"))
  if(geography_var == "lad22cd") json_filtered <- json %>% filter(!str_sub(lad22cd, 1, 1) %in% c("S", "N"))
  
  return(json_filtered)
  
}
