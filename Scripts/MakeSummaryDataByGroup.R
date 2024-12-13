# Name of script: MakeSummaryDataByGroup
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

make_summary_data_by_group <- function(data_epc,
                                       data_housing_type_census,
                                       lsoa_var,
                                       geo_level_var,
                                       housing_type_var,
                                       n_cutoff_conc_pred,
                                       group_vars,
                                       most_recent_only){
  
  # Get mean WF/SF by housing type and LSOA (we always want to use the smallest level geography)
  data_wf_sf_predicted <- data_epc %>%
    
    # Filter most recent EPCs only
    filter(most_recent == TRUE) %>%
    
    # Get percentage of properties with WF/SF by property type and LSOA
    summarise(wood_perc = mean(any_wood, na.rm = TRUE),
              sfa_perc = mean(any_sfa, na.rm = TRUE),
              epc = n(),
              .by = c(lsoa_var,
                      housing_type_var)) %>%
    
    # Filter rows where have fewer than 'n_cutoff_conc_pred' data points
    filter(epc > n_cutoff_conc_pred)
  
  # Get dataset of predicted number of WF/SF heat sources by geography var 
  # (aggregate over all LSOAs within that geography)
  data_n_wood_predicted <- data_housing_type_census %>%
    
    left_join(data_wf_sf_predicted, by = c(lsoa_var,
                                           housing_type_var)) %>%
  
    summarise(n_wood_predicted = sum(wood_perc * n_properties, na.rm = TRUE),
           n_sfa_predicted = sum(sfa_perc * n_properties, na.rm = TRUE),
           wood_perc_h_predicted = sum(wood_perc * n_properties * property_type_h / sum(n_properties * property_type_h, na.rm = TRUE), na.rm = TRUE) * 100,
           sfa_perc_predicted = sum(sfa_perc * n_properties * property_type_h / sum(n_properties * property_type_h, na.rm = TRUE), na.rm = TRUE) * 100,
           sfa_perc_all_properties_predicted = sum(sfa_perc * n_properties / sum(n_properties, na.rm = TRUE), na.rm = TRUE) * 100,
           n_properties_census = sum(n_properties, na.rm = TRUE),
           .by = geo_level_var)
  
  # Generate dataset of area in km2 and population by LSOA for later joining
  data_area_pop <- data_epc %>%
    
    # Select distinct values for population/area
    distinct(lsoa21cd, .keep_all = TRUE) %>%
    
    # Summarise to generate aggregated data
    summarise(num_people = sum(num_people, na.rm = TRUE), # Calculate total population by geographical area
              area_in_km2 = sum(area_in_km2, na.rm = TRUE), # Calculate total area by geographical area 
              .by = group_vars)
  
  # If 'most_recent_only' is TRUE, filter data by 'most_recent' indicator
  if(most_recent_only == TRUE) data_epc <- data_epc %>% filter(most_recent == TRUE)
  
  # Aggregate data using specified group vars
  summary_data <- data_epc %>%
    
    # Remove observations where group indicator is missing
    filter(if_all(group_vars, ~ !is.na(.))) %>%
    
    # Aggregate summary variables by LSOA-year group
    summarise(
      
      # Percentage of all properties with WF/SF heat source
      wood_perc = mean(any_wood, na.rm = TRUE),
      sfa_perc = mean(any_sfa, na.rm = TRUE),
      
      # Sum relevant variables
      across(all_of(c("any_sfa_m",
                              "any_sfa_s",
                              "wood_m",
                              "wood_s",
                              "any_sfa",
                              "any_sfa_h",
                              "any_wood",
                              "any_wood_h",
                              "pre_1950")), ~ sum(., na.rm = TRUE)),
      
      # Total number of EPCs
      epc = n(),
              
      # Total number of EPCs on houses
      epc_house_total = sum(property_type_census %in% c("Detached",
                                                        "Semi Detached",
                                                        "Terrace"), na.rm = TRUE),
      
      # Average socio-economic indicators across smallest grouping variable
      imd_score = mean(imd_score, na.rm = TRUE), 
      imd_decile = mean(imd_decile, na.rm = TRUE),
      white_pct = mean(white_pct, na.rm = TRUE),
      median_age_mid_2022 = mean(median_age_mid_2022, na.rm = TRUE),
      urban = mean(urban, na.rm = TRUE),
      
      # Indicator for whether any part of geography is in an SCA
      # If there is any overlap with an SCA, the geography is classified as 1
      sca_area = case_when(mean(sca_area, na.rm = TRUE) > 0 ~ 1,
                           .default = 0),
      
      .by = group_vars) %>%
    
    # Join to area/population data
    full_join(data_area_pop, by = group_vars) %>%
    
    # Create new variables for concentration of SFAs per km2 and proportion of EPCs
    # with SFAs (restricted to houses)
    mutate(sfa_conc = any_sfa/area_in_km2,
           
           wood_conc = any_wood/area_in_km2,
           
           sfa_perc_h = (any_sfa_h/epc_house_total)*100,
           
           wood_perc_h = (any_wood_h/epc_house_total)*100,
           .by = group_vars) %>%
    
    # Convert NaNs to NAs
    mutate(across(where(is.numeric), ~ na_if(., NaN))) %>%
    
    # Left join to predicted number of WF heat sources
    left_join(data_n_wood_predicted, by = geo_level_var) %>%
    
    # Generate predicted WF/SF concentration
    mutate(sfa_conc_pred = n_sfa_predicted / area_in_km2,
           wood_conc_pred = n_wood_predicted / area_in_km2)
  
  return(summary_data)
}
