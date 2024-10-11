# Name of script: MakeSummaryDataByGeography
# Description: Defines function to make aggregate level dataset by arbitrary group vars
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 03-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 20-09-2024
# Update notes: Changed function to refer to arbitrary grouping variables

# Comments ---------------------------------------------------------------------

# Define function to aggregate main data with all covariates to a summary dataset at an arbitrary
# geographical level (e.g. ward, LSOA, LAD, region)

# Define function to make summary data by group --------------------------------

make_summary_data_by_group <- function(data, 
                                           lsoa_var,
                                           group_vars,
                                           most_recent_only){
  
  # Generate dataset of area in km2 and population by LSOA for later joining
  data_area_pop_lsoa <- data %>%
    
    # Select distinct values for population/area
    distinct({{lsoa_var}}, .keep_all = TRUE) %>%
    
    # Summarise to generate aggregated data
    summarise(num_people = sum(num_people, na.rm = TRUE), # Calculate total population by geographical area
              area_in_km2 = sum(area_in_km2, na.rm = TRUE), # Calculate total area by geographical area 
              .by = group_vars)
  
  # If 'most_recent_only' is TRUE, filter data by 'most_recent' indicator
  if(most_recent_only == TRUE) data <- data %>% filter(most_recent == TRUE)
  
  # Aggregate data using specified group vars
  summary_data <- data %>%
    
    # Remove observations where group indicator is missing
    filter(if_all(group_vars, ~ !is.na(.))) %>%
    
    # Aggregate summary variables by LSOA-year group
    summarise(across(all_of(c("any_sfa_m",
                              "any_sfa_s",
                              "wood_m",
                              "wood_s",
                              "any_sfa",
                              "any_sfa_h",
                              "any_wood",
                              "any_wood_h",
                              "pre_1950")), ~ sum(., na.rm = TRUE)),
              
              # Total number of EPCS
              epc = n(),
              
              # Total number of EPCs on houses
              epc_house_total = sum(property_type %in% c("bungalow", 
                                                                "house"), na.rm = TRUE),
              
              # Average IMD score/decile across smallest grouping variable
              imd_score = mean(imd_score, na.rm = TRUE), 
              imd_decile = mean(imd_decile, na.rm = TRUE),
              
              # Indicator for whether any part of geography is in an SCA
              # If there is any overlap with an SCA, the geography is classified
              # as 1
              sca_area = case_when(mean(sca_area, na.rm = TRUE) > 0 ~ 1,
                                   .default = 0),
              
              .by = group_vars) %>%
    
    # Join to area/population data
    full_join(data_area_pop_lsoa, by = group_vars) %>%

    # Create new variables for concentration of SFAs per km2 and proportion of EPCs
    # with SFAs (restricted to houses)
    mutate(sfa_conc = any_sfa/area_in_km2,

           wood_conc = any_wood/area_in_km2,

           sfa_epc = (any_sfa_h/epc_house_total)*100,

           wood_epc = (any_wood_h/epc_house_total)*100,
           .by = group_vars) %>%
    
    # Convert NaNs to NAs
    mutate(across(where(is.numeric), ~ na_if(., NaN)))
  
  return(summary_data)
}
