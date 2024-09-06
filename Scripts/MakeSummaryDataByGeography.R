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
                                           by_year,
                                           most_recent_only){
  
  # If 'most_recent_only' == TRUE, filter data to only most recent EPCs
  if(most_recent_only == TRUE) data <- data %>% filter(most_recent == 1)
  
  # Set geography var to group var
  group_vars <- c(geography_var)
  
  # If 'by_year' is TRUE, append 'year' as a grouping variable
  if(by_year == TRUE) group_vars <- append(group_vars, "year")
  
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
              area_in_km2 = mean(area_in_km2, na.rm = TRUE),
              .by = group_vars) %>%
    
    # Create new variables for concentration of SFAs per km2 and proportion of EPC
    # (house) properties with SFAs
    mutate(sfa_conc = any_sfa/area_in_km2,
           
           wood_conc = any_wood/area_in_km2,
           
           sfa_epc = (any_sfa_h/epc_house_total)*100,
           
           wood_epc = (any_wood_h/epc_house_total)*100,
           .by = group_vars)
}