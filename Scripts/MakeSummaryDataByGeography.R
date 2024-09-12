# Name of script: MakeSummaryDataByGeography
# Description: Defines function to make aggregate level dataset at arbitrary
# geographical level
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 03-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 03-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# Define function to aggregate main data with all covariates to a summary dataset at an arbitrary
# geographical level (e.g. ward, LSOA, LAD, region)

# Define function to make summary data at geography-year level -----------------

make_summary_data_by_geography <- function(data, 
                                           geography_var, 
                                           by_year){
  
  # Set geography var to group var
  group_vars <- c(geography_var, "rgn22nm")
  
  # Generate dataset of area in km2 and population for later joining
  area_pop_data <- data %>%
    
    # Select distinct values for population/area
    distinct(lsoa21cd, .keep_all = TRUE) %>%
    
    # Summarise to generate aggregated data
    summarise(num_people = sum(num_people, na.rm = TRUE), # Calculate total population by geographical area
              area_in_km2 = sum(area_in_km2, na.rm = TRUE), # Calculate total area by geographical area 
              .by = group_vars)
  
  # If 'by_year' is TRUE, append 'year' as a grouping variable
  if(by_year == TRUE){
    
    group_vars_summary <- append(group_vars, "year")
    
  } else {
    
    group_vars_summary <- c(geography_var, "rgn22nm")
    
  }
  
  # Aggregate data using specified group vars
  summary_data <- data %>%
    
    # Remove observations where couldn't match to statistical geography (should report the N)
    filter(!is.na(geography_var)) %>%
    
    # Aggregate summary variables by LSOA-year group
    summarise(across(c(any_sfa_m,
                              any_sfa_s,
                              wood_m,
                              wood_s,
                              any_sfa,
                              any_sfa_h,
                              any_wood,
                              any_wood_h,
                              pre_1950,
                              detached,
                              semidetached,
                              terrace,
                              flat,
                              accom_other,
                              house_form_missing), ~ sum(., na.rm = TRUE)),
              epc = n(),
              epc_house_total = sum(
                       detached, semidetached, terrace,
                       house_form_missing),
              imd_score = mean(imd_score, na.rm = TRUE), # Here I take a raw average IMD score/decile by geography
              imd_decile = mean(imd_decile, na.rm = TRUE),
              .by = group_vars_summary) %>%
    
    # Join to area/population data
    full_join(area_pop_data, by = group_vars) %>%

    # Create new variables for concentration of SFAs per km2 and proportion of EPC
    # (house) properties with SFAs
    mutate(sfa_conc = any_sfa/area_in_km2,

           wood_conc = any_wood/area_in_km2,

           sfa_epc = (any_sfa_h/epc_house_total)*100,

           wood_epc = (any_wood_h/epc_house_total)*100,
           .by = group_vars_summary)
  
  return(summary_data)
}