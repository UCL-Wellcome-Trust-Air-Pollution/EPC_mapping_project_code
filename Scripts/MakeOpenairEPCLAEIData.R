

make_openair_epc_laei_data <- function(data_openair_epc,
                                       data_laei){
  
  data_openair_epc_laei <- data_openair_epc %>%
    
    # Filter if NA coordinates
    filter(!is.na(longitude) & !is.na(latitude)) %>%
    
    # Set as sf object
    st_as_sf(coords = c("longitude",
                        "latitude")) %>%
    
    # Set CRS
    st_set_crs(4326) %>%
    
    # Transform to match LAEI CRS
    st_transform(3857) %>%
    
    # Join to LAEI data
    st_join(data_laei, join = st_within) %>%
    
    # Remove unmatched grid ids (outside of London)
    filter(!is.na(grid_id)) %>%
    
    # Set as df
    as_tibble() %>%
    
    # Remove geometry variable
    select(!geometry)
  
  return(data_openair_epc_laei)
  
}