# Name of script: UtilityFunctions
# Description:  Defines set of utility functions which are used in other scripts
# and geographical resolution
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 04-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 04-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------


# Function to generate dataframe of percentage of properties by Census housing type
# for OS vs. EPC data
make_data_housing_type_os_epc <- function(data_os,
                                          data_epc){
  
  # Make data frame of percentage and N of housing type for OS data
  data_housing_type_os <- data_os %>%
    
    # Filter missing housing types, as these would not be used in calculations
    filter(property_type_census != "House form missing") %>%
    
    # Summarise row count by housing type
    summarise(n_os = n(), .by = property_type_census) %>%
    
    # Mutate to give percentage
    mutate(perc_os = n_os / sum(n_os))
  
  # Make data frame of percentage and N of housing types for EPC data
  data_housing_type_epc <- data_epc %>%
    
    # Keep only unique records
    distinct(uprn, .keep_all = TRUE) %>%
    
    # Filter missing housing types, as these would not be used in calculations
    filter(property_type_census != "House form missing") %>%
    
    # Summarise row count by housing type
    summarise(n_epc = n(), .by = property_type_census) %>%
    
    # Mutate to give percentage
    mutate(perc_epc = n_epc / sum(n_epc))
  
  # Bind data frames together
  data_housing_type_os_epc <- data_housing_type_os %>%
    
    left_join(data_housing_type_epc, by = "property_type_census")
                                    
}

# Function to download and prepare OS AddressBase data -------------------------

get_os_data <- function(data_os_path){
  
  data_os <- read_parquet(data_os_path) #%>%
    
    # # Clean names
    # clean_names() %>%
    # 
    # # Keep only records which are still active (i.e. end_date is NA)
    # filter(is.na(end_date)) %>%
    # 
    # select(!end_date) %>%
    # 
    # # Filter only residential properties (classification code starts with 'R')
    # filter(str_sub(classification_code, 1, 1) == "R") %>%
    # 
    # # Mutate new variable capturing Census property types
    # mutate(property_type_census = factor(case_when(classification_code == "RD02" ~ "Detached",
    #                                     classification_code == "RD03" ~ "Semi Detached",
    #                                     classification_code == "RD04" ~ "Terrace",
    #                                     classification_code == "RD06" ~ "Flat",
    #                                     classification_code %in% c("RD01",
    #                                                                "RD07",
    #                                                                "RD08",
    #                                                                "RD10") ~ "Other accommodation",
    #                                     .default = "House form missing")))
  
}

# Function to calculate correlation coefficient for arbitrary dataframe --------

get_corr <- function(data, 
                     x_var, 
                     y_var, 
                     idx, 
                     correlation_method){
  
  # Calculate correlation of specified df cols
  corr <- cor(data[[y_var]][idx], 
              data[[x_var]][idx],
              method = correlation_method)
  
  return(corr)
  
}

# Function to calculate difference in correlation coefficients 
# for arbitrary dataframe with a filter var ------------------------------------

get_corr_diff <- function(data, 
                     x_var, 
                     y_var,
                     season_var,
                     idx, 
                     correlation_method){
  
  # Subset data based on idx selected
  data_idx <- data[idx,]
  
  # Extract data for winter and summer separately
  data_winter <- data_idx[data_idx[[season_var]] == "Winter",]
  data_summer <- data_idx[data_idx[[season_var]] == "Summer",]
  
  # Calculate correlation of specified df cols
  corr_winter <- cor(data_winter[[y_var]], 
              data_winter[[x_var]],
              method = correlation_method)
  
  # Calculate correlation of specified df cols
  corr_summer <- cor(data_summer[[y_var]], 
                     data_summer[[x_var]],
                     method = correlation_method)
  
  # Get difference between two correlation coefficients
  corr_diff = corr_winter - corr_summer
  
  return(corr_diff)
  
}

# Function to load shapefile from path and filter English/Welsh LSOAs ----------

get_shapefile <- function(shapefile_path,
                          geography_var){
  
  # Get shapefile
  shp <- read_sf(shapefile_path) %>%
    
    # Clean names
    clean_names() %>%
    
    # Filter out Scottish/Northern Irish geographies
    filter(!str_sub({{geography_var}}, 1, 1) %in% c("S", "N"))
  
  return(shp)
  
}

# Function to get the 'ith' percentile of a dataframe column -------------------

get_percentile <- function(variable, percentile){
  
  percentile <- quantile(variable, percentile, na.rm = TRUE)
  
  return(percentile)
  
}

# Define function to get summary of housing type by OA from Census -------------

make_data_housing_type_census <- function(path_data_housing_type_census,
                                          path_region,
                                          path_ward){
  
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
  
  # Load ward lookup data from path
  data_ward <- vroom(here(path_ward)) %>%
    
    # clean names
    clean_names() %>%
    
    # Select relevant columns
    select(lsoa21cd, 
           lsoa21nm, 
           wd22cd, 
           wd22nm) %>%
    
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
  
  # Load housing type data from path and join to geographic identifiers
  data_housing_type_census <- vroom(path_data_housing_type_census, col_select = c("Accommodation type (8 categories)",
                                                                                  "Lower layer Super Output Areas Code",             
                                                                                  "Observation")) %>% 
    # Clean names
    clean_names() %>%
    
    # Mutate character to factors
    mutate(across(where(is.character), as.factor)) %>%
    
    # Rename variables
    rename(lsoa21cd = lower_layer_super_output_areas_code,
           property_type_census = accommodation_type_8_categories) %>%
    
    # Recast accommodation categories to match EPC data
    mutate(property_type_census = case_when(property_type_census == "In a purpose-built block of flats or tenement" ~ "Flat",
                                            property_type_census %in% c("Part of a converted or shared house, including bedsits",
                                                                        "Part of another converted building, for example, former school, church or warehouse",
                                                                        "In a commercial building, for example, in an office building, hotel or over a shop",
                                                                        "A caravan or other mobile or temporary structure") ~ "Other accommodation",
                                            property_type_census == "Semi-detached" ~ "Semi Detached",
                                            property_type_census == "Terraced" ~ "Terrace",
                                            .default = property_type_census)) %>%
    
    # SUmmarise across property type and LSOA (multiple rows for 'other accommodation')
    summarise(n_properties = sum(observation), .by = c("property_type_census",
                                                        "lsoa21cd")) %>%
    
    # Create indicator variable for property type = 'house' (for prevalence metric)
    mutate(property_type_h = case_when(property_type_census %in% c("Detached",
                                                                   "Semi Detached",
                                                                   "Terrace") ~ 1,
                                       .default = 0)) %>%
    
    # Keep all non-zero observations
    filter(n_properties > 0) %>%
    
    # Create new variable for proportion of all properties equal to each property type
    mutate(property_type_perc = n_properties / sum(n_properties), .by = "lsoa21cd") %>%
    
    left_join(data_ward, by = "lsoa21cd")
  
}

# Functions for formatting tables ----------------------------------------------

# Define function to get summary table by EPC number 
make_summary_tab_by_epc_number <- function(data,
                                           n_epc){
  
  summary_tab <- data %>%
    
    # Filter total EPC equal to specified number
    filter(total_epc == n_epc) %>%
    
    # Filter only houses
    filter(property_type_census %in% c("Detached",
                                       "Semi Detached",
                                       "Terrace")) %>%
    
    # Summarise wood fuel prevalence by EPC number and property type
    summarise(wood_perc_h = mean(any_wood_h, na.rm = TRUE),
              n = n(),
              .by = c(epc_number,   
                      property_type_census)) %>%
    
    # Pivot wider
    pivot_wider(id_cols = property_type_census,
                         names_from = epc_number,
                         values_from = c(wood_perc_h,
                                         n)) %>%
    
    # Make new column to indicate number of EPCs (to use as group var)
    mutate(n_epc = n_epc) %>%
    
    # Arrange alphabetically
    arrange(property_type_census)
  
  return(summary_tab)
  
}

# Wrapper function to make summary tables on WF prevalence for different EPC numbers
make_summary_tabs_by_epc_number <- function(data,
                                            max_n_epc) {
  
  # Make list of tables by different EPC numbers (starting at 2 and ending at 'max_n_epc')
  tab_list <- lapply(rep(2:max_n_epc), make_summary_tab_by_epc_number, data = data)
  
  # Bind tables together, filling missing columns with NA
  tab_n_epc <- bind_rows(tab_list)
  
  return(tab_n_epc)
}
