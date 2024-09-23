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
                                  path_lsoa11_lsoa21_lookup,
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
    rename("lsoa11cd" = "lsoa_code",
           "imd_score" = "wimd_2019")
  
  # Bind England and Wales IMD datasets together
  data_imd <- bind_rows(data_imd_eng,
                        data_imd_wales)
  
  # Load LSOA11 code to LSOA21 code lookup data
  data_lsoa11cd_lsoa21cd_lookup <- vroom(here(path_lsoa11_lsoa21_lookup),
                                         col_select = c("LSOA11CD",
                                                        "LSOA21CD")) %>%
    
    # Clean names
    clean_names()
  
  # Left join LSOA21 codes with IMD data using the 2011 codes - this will generate
  # a dataset of IMD scores using the 2021 LSOA codes, with IMD score defined on the
  # 2011 LSOA codes
  data_imd <- data_lsoa11cd_lsoa21cd_lookup %>%
    
    # Left join to retain all LSOA21 codes
    left_join(data_imd, by = "lsoa11cd") %>%
    
    # Where multiple 2011 LSOAs correspond to one 2021 LSOA, I take the 
    # average IMD score across all corresponding 2011 LSOAs (this should give a 
    # reasonable approximation since all LSOAs are similar sized populations by 
    # definition)
    summarise(imd_score = mean(imd_score, na.rm = TRUE),
              .by = lsoa21cd)
  
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
    
    # Clean names
    clean_names() %>%
    
    # Select relevant columns
    select(wd22cd,
           lad22cd,
           lad22nm,
           rgn22nm,
           ctry22nm)
  
  data_ward <- vroom(here(path_ward)) %>%
    
    # clean names
    clean_names() %>%
    
    # Select relevant columns
    select(lsoa21cd, lsoa21nm, wd22cd, wd22nm) %>%
    
    # Left join to region data
    left_join(data_region, by = "wd22cd")
  
  # There are four duplicated LSOAs - this is because the electoral ward of
  # Hunmanby and Sherburn is shared between the LAs of Ryedale and Scarborough.
  # Here, I filter the duplicated LSOAs by retaining the row where the LSOA21 name
  # Matches the LAD22 name - e.g. 'Ryedale 004C' would be assigned to 'Ryedale'
  data_ward_dupes <- get_dupes(data_ward, lsoa21cd) %>%
    
    select(!dupe_count) %>%
    
    # Detect string for Local Authority not within the LSOA name (then use 
    # to filter full list of LSOAs above)
    filter(!str_detect(lsoa21nm, lad22nm))
  
  # Filter rows from 'data_ward' based on the dataframe of duplicated values
  # using anti join
  data_ward <- data_ward %>%
    
    anti_join(data_ward_dupes)
  
  # Create LSOA-level lookup dataset
  
  data_lsoa_lookup <- data_lsoa_size %>%
    
    # Left join to IMD data (we only want to keep LSOA codes from the 'LSOA_size' 
    # dataset as these are the more recent 2021 codes)
    left_join(data_imd, by = "lsoa21cd") %>%
    
    # Full join to ethnicity data
    full_join(data_ethnicity, by = "lsoa21cd") %>%
    
    # Full join to ward names data
    full_join(data_ward, by = "lsoa21cd") %>%
    
    # Mutate region variable to treat Wales as a region (since IMD calculated differently)
    mutate(rgn22nm = ifelse(ctry22nm == "Wales", ctry22nm, rgn22nm)) %>%
    
    # Remove 'ctry22nm' column
    select(-ctry22nm) %>%
    
    # Mutate IMD and white ethnicity percentage deciles (as factors) by region
    mutate(imd_decile = ntile(desc(imd_score), n = 10),
           white_dec = ntile(desc(white_pct), n = 10),
           .by = "rgn22nm")
  
  return(data_lsoa_lookup)

}
