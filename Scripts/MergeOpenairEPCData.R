# Name of script: MergeOpenairEPCData
# Description:  Defines function to construct measure of concentration of WF heat
# sources around monitors derived from openair data
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 31-10-2024
# Latest update by: Calum Kennedy
# Latest update on: 31-10-2024
# Update notes: 

# Comments ---------------------------------------------------------------------



# Define function to merge openair data with EPC data --------------------------

merge_openair_epc_data <- function(data_openair,
                                    data_epc,
                                    long_var_epc,
                                    lat_var_epc,
                                    buffer_radius){
  
  # Get unique monitoring sites from openair
  unique_sites <- distinct(data_openair, site, .keep_all = TRUE) %>%
    
    # Filter if NA coordinates
    filter(!is.na(longitude) & !is.na(latitude))
  
  # Set unique sites as sf object using 'set_spatial_points' function
  unique_sites_sf <- set_spatial_points(unique_sites,
                                          "longitude",
                                          "latitude")
  
  # Get main EPC data and set as sf object, retaining only long/lat columns
  data_epc_sf <- data_epc %>% 
    
    select(long_var_epc,
           lat_var_epc,
           most_recent,
           any_wood,
           sca_area) %>%
    
    filter(most_recent == TRUE) %>%
    
    # Set as SF (need to initially set CRS 3857 as this was defined in previous
    # data cleaning, before transforming to BNG27700 as this is in metres)
    st_as_sf(coords = c(long_var_epc,
                        lat_var_epc), crs = 3857) %>%
    
    st_transform(27700)
  
  # Create an st_buffer object using the 'unique_sites_sf' object to capture
  # the number of WF heat sources around that site
  unique_sites_buffer <- st_buffer(unique_sites_sf, dist = buffer_radius)
  
  # Spatial join the EPC data to the generated buffer
  data_epc_buffer_joined <- data_epc_sf %>%
    
    # Join to EPC data using the 'st_within' command
    st_join(unique_sites_buffer, join = st_within)
  
  # Summarise count data by site for merging back to main openair data
  unique_sites_with_counts <- data_epc_buffer_joined %>%
    
    # Set as dataframe
    as.data.frame() %>%
    
    # Filter non-matched rows
    filter(!is.na(code)) %>%
    
    # Count number of WF and total number of heat sources within specified radius
    summarise(n_wf = sum(any_wood == 1, na.rm = TRUE),
              n = n(),
              sca_area = mean(sca_area, na.rm = TRUE),
              .by = code)
  
  # Left join counts data to main openair data
  data_openair_with_counts <- data_openair %>%
    
    left_join(unique_sites_with_counts, by = "code") %>%
    
    # Generate necessary variables for plotting
    mutate(season = case_when(month %in% c(6, 7, 8) ~ "Summer",
                              month %in% c(12, 1, 2) ~ "Winter",
                              month %in% c(3, 4, 5) ~ "Spring",
                              month %in% c(9, 10, 11) ~ "Autumn"),
           weekend = case_when(day %in% c("Saturday", 
                                         "Sunday") ~ 1, .default = 0),
           
           # Variable for each unique day of year (for calculating grouped variables below)
           day_id = lubridate::yday(date),
           
           # Indicator variable for peak burning times (1900 - 0100)
           peak = case_when(hour %in% c("19", 
                                        "20", 
                                        "21", 
                                        "22", 
                                        "23", 
                                        "00", 
                                        "01") ~ 1, .default = 0),
    
    # Indicator variable for non-peak burning
    non_peak = case_when(hour %in% c("05",
                                     "06",
                                     "07",
                                     "08",
                                     "09",
                                     "10",
                                     "11",
                                     "12",
                                     "13",
                                     "14",
                                     "15",
                                     "16",
                                     "17") ~ 1, .default = 0)) %>%
    
    # Get difference in mean PM during peak time vs. during non-peak time
    mutate(pm2.5_diff_peak = mean(pm2.5[peak==1], na.rm = TRUE) - mean(pm2.5[non_peak==1], na.rm = TRUE),
           log_n_wf = ifelse(n_wf > 0, log(n_wf), 0), 
           log_n = ifelse(n > 0, log(n), 0),
           .by = c(code, day_id))
  
  return(data_openair_with_counts)
}
