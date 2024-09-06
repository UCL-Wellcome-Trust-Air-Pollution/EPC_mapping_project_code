# Name of script: MakeLSOALookupData
# Description:  Loads data sources (IMD, ethnicity, etc) to make LSOA-level lookup data 
# data to merge with main EPC data
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 06-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 06-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------



# Define function to make LSOA-level lookup data -------------------------------


make_lsoa_lookup_data <- function(path_lsoa_size,
                                  path_imd_eng,
                                  path_imd_wales,
                                  path_ethnicity,
                                  path_region,
                                  path_ward){

  # Load LSOA size dataset
  data_lsoa_size <- vroom(here(path_lsoa_size), col_select = c("LSOA21CD",
                                                               "Extent of the Realm (Area in KM2)")) %>%
    
    # Rename variables
    rename("lsoa21cd" = "LSOA21CD",
           "area_in_km2" = "Extent of the Realm (Area in KM2)")
  
  # Load English IMD dataset
  data_imd_eng <- read_excel(here(path_imd_eng),
                             sheet = "IoD2019 Scores", col_names = TRUE) %>%
    
    # Select relevant columns
    select("LSOA code (2011)",
           "Index of Multiple Deprivation (IMD) Score") %>%
    
    # Rename columns
    rename("lsoa11cd" = "LSOA code (2011)",
           "imd_score" = "Index of Multiple Deprivation (IMD) Score")
  
  # Load Welsh IMD dataset
  data_imd_wales <- read_ods(here(path_imd_wales),
                             sheet = "Data", range = "A4:D1913", col_names = TRUE) %>%
    
    # Clean names
    clean_names() %>%
    
    # Select relevant columns
    select(lsoa_code, wimd_2019) %>%
    
    # Rename columns
    rename(lsoa11cd = "lsoa_code",
           imd_score = "wimd_2019")
  
  # Bind England and Wales IMD datasets together
  data_imd <- bind_rows(data_imd_eng,
                        data_imd_wales)
  
  # Load ethnicity dataset
  data_ethnicity <- vroom(here(path_ethnicity)) %>%
    
    # Clean names
    clean_names() %>%
    
    # Rename columns
    rename(lsoa21cd = lower_layer_super_output_areas_code,
           ethnic_grp = ethnic_group_20_categories) %>%
    
    # Generate new indicator for count of people from white ethnic background by small area
    mutate(white_eth = case_when(ethnic_grp %in% c("White: English, Welsh, Scottish, Northern Irish or British",
                                                   "White: Irish",
                                                   "White: Gypsy or Irish Traveller",
                                                   "White: Roma",
                                                   "White: Other White") ~ observation, 
                                 .default = 0)) %>%
    
    # Group by LSOA level to aggregate
    group_by(lsoa21cd) %>%
    
    # Aggregate dataset to LSOA level with total sum of people, people from white background
    # and percentage of people from white background
    summarise(num_people = sum(observation),
              
              num_white = sum(white_eth)) %>%
    
    mutate(white_pct = (num_white/num_people)*100)
  
  # Load ward-level data and merge with region-country lookup
  data_region <- vroom(here(path_region)) %>% 
    
    clean_names() %>%
    
    select(-object_id, -wd22nm)
  
  data_ward <- vroom(here(path_ward)) %>%
    
    # clean names
    clean_names() %>%
    
    # Select relevant columns
    select(lsoa21cd, lsoa21nm, wd22cd, wd22nm, ltla22nm) %>%
    
    left_join(data_region, by = "wd22cd")
  
  # Create LSOA-level lookup dataset
  
  data_lsoa_lookup <- data_lsoa_size %>%
    
    # Left join to IMD data (we only want to keep LSOA codes from the 'LSOA_size' 
    # dataset as these are the more recent 2021 codes)
    left_join(data_imd, by = c("lsoa21cd" = "lsoa11cd")) %>%
    
    # Full join to ethnicity data
    full_join(data_ethnicity, by = "lsoa21cd") %>%
    
    # Full join to ward names data
    full_join(data_ward, by = "lsoa21cd") %>%
    
    # Mutate region variable to treat Wales as a region (since IMD calculated differently)
    mutate(rgn22nm = ifelse(ctry22nm == "Wales", ctry22nm, rgn22nm)) %>%
    
    # Mutate IMD and white ethnicity percentage deciles by region
    mutate(imd_decile = ntile(desc(imd_score), n = 10),
           white_dec = ntile(desc(white_pct), n = 10),
           .by = "rgn22nm")
  
  return(data_lsoa_lookup)

}
