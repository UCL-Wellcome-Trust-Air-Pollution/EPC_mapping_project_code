# Name of script: CleanDataEPC
# Description:  Cleans downloaded Energy Performance Certificate data and saves as parquet file 
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 23-08-2024
# Latest update by: Calum Kennedy
# Latest update on: 23-08-2024
# Update notes: I have included data for 2023 since we now have a full year of data

# Comments ---------------------------------------------------------------------

# We could also include 2024 data (up to June) in any anaylsis of percentages - seems unlikely that
# what time of year a property gets an EPC would be correlated with any meaningful variables

# Define function to clean main EPC data ---------------------------------------

clean_data_epc <- function(file){
  
  # Define inputs for data cleaning --------------------------------------------
  
  # List of strings to identify SFA properties
  any_sfa_lookup <- c("wood", "coal", "mineral", "anthracite", "coed", "glo", 
                      "smokeless", "dual fuel", "mwynau")
  
  # List of strings to identify wood SFA properties
  wood_sfa_lookup <- c("wood", "coed", "dual fuel")
  
  # Define bands to recode construction age to pre Clean Air Act 1956 when chimneys less common
  pre_1950_bands <- c("england and wales: 1900-1929", "england and wales: 1930-1949", 
                      "england and wales: before 1900","1700", "1800", "1805", "1820", 
                      "1825", "1849", "1850", "1867", "1876", "1880", "1885", "1889",
                      "1890", "1900", "1902", "1910", "1915", "1920", "1929", "1930", 
                      "1935", "1940", "1950")
  
  # Generate SQL query to clean data ---------------------------------------------
  
  # Establish a connection
  con <- dbConnect(duckdb(), dbdir = here(paste0("Data/raw/epc_data/", file)))
  
  # Generate SQL query and store result as lazy datatable (allows you to access 
  #data.table functionality using dplyr code)
  data_epc_cleaned <- dbReadTable(con, "data_epc") %>%
    
    # Clean names using Janitor
    clean_names() %>%
    
    # Filter years in 2009-2024
    filter(year > 2008) %>%
    
    # Recode construction age to pre Clean Air Act 1956
    mutate(pre_1950 = if_else(construction_age_band %in% pre_1950_bands, 1, 0)) %>%
    
    # Generate identifier for whether main/secondary heat source is in 'any SFA' or 'wood SFA' 
    # - categories defined in 'Define inputs for data cleaning and taken from original 
    # 'epc_sfa_cleaning_20240807.R' script (set missing values to NA)
    mutate(any_sfa_m = case_when(str_detect(mainheat_description, paste0(any_sfa_lookup, collapse = "|")) ~ 1,
                                 is.na(mainheat_description) ~ NA,
                                 .default = 0),
           
           wood_m = case_when(str_detect(mainheat_description, paste0(wood_sfa_lookup, collapse = "|")) ~ 1,
                              is.na(mainheat_description) ~ NA,
                              .default = 0),
           
           any_sfa_s = case_when(str_detect(secondheat_description, paste0(any_sfa_lookup, collapse = "|")) ~ 1,
                                 is.na(secondheat_description) ~ NA,
                                 .default = 0),
           
           wood_s = case_when(str_detect(secondheat_description, paste0(wood_sfa_lookup, collapse = "|")) ~ 1,
                              is.na(secondheat_description) ~ NA,
                              .default = 0)) %>%
    
    # Clean tenure variable
    mutate(tenure = case_when((is.na(tenure) | tenure == "unknown") ~ NA_character_,
                              tenure == "not defined - use in the case of a new dwelling for which the intended tenure in not known. it is not to be used for an existing dwelling" ~ "newbuild",
                              tenure == "rental (private)" ~ "rented (private)",
                              tenure == "rental (social)" ~ "rented (social)",
                              .default = tenure)) %>%
    
    # Create new variable for 'property type' similar to 2021 Census
    mutate(property_type_census = case_when(property_type %in% c("bungalow",
                                                                 "house") &
                                              built_form == "detached" ~ "Detached",
                                            property_type %in% c("bungalow",
                                                                 "house") &
                                              built_form == "semi-detached" ~ "Semi Detached",
                                            property_type %in% c("bungalow",
                                                                 "house") &
                                              built_form %in% c("mid-terrace",
                                                                "end-terrace",
                                                                "enclosed end-terrace",
                                                                "enclosed mid-terrace") ~ "Terrace",
                                            property_type %in% c("bungalow",
                                                                 "house") &
                                              is.na(built_form) ~ "House Form Missing",
                                            property_type %in% c("flat",
                                                                 "maisonette") ~ "Flat",
                                            property_type == "park home" ~ "Other accommodation",
                                            .default = NA))  %>%
    
    # Generate indicator variable for SFA as main/secondary heat source overall and in houses only
    mutate(
      any_sfa = case_when(any_sfa_m == 1 | any_sfa_s == 1 ~ 1,
                          any_sfa_m == 0 & any_sfa_s == 0 ~ 0,
                          .default = NA),
      
      any_wood = case_when(wood_m == 1 | wood_s == 1 ~ 1,
                           wood_m == 0 & wood_s == 0 ~ 0,
                           .default = NA),
      
      any_sfa_h = case_when((any_sfa_m == 1 | any_sfa_s == 1) &
                              property_type_census %in% c("Detached",
                                                   "Semi Detached",
                                                   "Terrace") ~ 1,
                            (any_sfa_m == 0 & any_sfa_s == 0) &
                              (property_type_census %in% c("Detached",
                                                            "Semi Detached",
                                                            "Terrace")) ~ 0,
                            .default = NA),
      
      any_wood_h = case_when((wood_m == 1 | wood_s == 1) &
                             property_type_census %in% c("Detached",
                                                         "Semi Detached",
                                                         "Terrace") ~ 1,
                             (wood_m == 0 & wood_s == 0) &
                               (property_type_census %in% c("Detached",
                                                     "Semi Detached",
                                                     "Terrace")) ~ 0,
                             .default = NA)
    ) %>%
    
    # Convert uprn to numeric variable
    mutate(uprn = as.numeric(uprn)) %>%
    
    # Clean postcode variable to remove whitespace and set to lowercase
    mutate(postcode = tolower(str_replace_all(postcode, fixed(" "), ""))) %>%
    
    # Remove unused variables
    select(!c(construction_age_band,
              mainheat_description,
              secondheat_description)) %>%
    
    # Filter duplicated rows
    distinct() %>%
    
    # Mutate characters to factors
    mutate(across(where(is.character), as.factor))
  
  # Close connection
  dbDisconnect(con)
  
  # Return 'data_epc_cleaned'
  return(data_epc_cleaned)
  
} 
