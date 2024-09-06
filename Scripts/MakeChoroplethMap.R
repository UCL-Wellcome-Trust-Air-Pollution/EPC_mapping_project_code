# Name of script: MakeChoroplethMap
# Description:  Defines function to produce choropleth map of UK given arbitrary dataset
# and geographical resolution
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 03-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 03-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# Defines function to produce choropleth map of UK at arbitrary geographical resolution, 
# given an arbitrary dataset

# Define map function ----------------------------------------------------------

make_choropleth_map <- function(fill_data, 
                                fill_var, 
                                fill_boundary_data, 
                                join_var, 
                                map_boundary_data, 
                                boundary_id_var, 
                                london_only,
                                legend_title, 
                                winsorise, 
                                lower_perc = 0.05, 
                                upper_perc = 0.95){
  
  # If 'winsorise' is TRUE, winsorise upper and lower percentiles of fill variable (default is 5th and 95th percentile)
  if(winsorise) fill_data <- mutate(fill_data, "{{fill_var}}" := case_when({{fill_var}} > get_percentile({{fill_var}}, upper_perc) ~ get_percentile({{fill_var}}, upper_perc),
                                                                       {{fill_var}} < get_percentile({{fill_var}}, lower_perc) ~ get_percentile({{fill_var}}, lower_perc),
                                                                       .default = {{fill_var}}))
  
  # Join boundary data to fill data
  data_to_map <- fill_boundary_data %>%
    
    left_join(fill_data, by = join_var)
  
  # If 'london_only' == TRUE, filter fill data to only London polygons (else nothing)
  if(london_only) data_to_map <- filter(data_to_map, str_sub(lad22cd, 1, 3) == "E09")
    
    # Generate main shape object
    choropleth_map <- tm_shape(data_to_map) +

    # Remove title for now - see if can specify dynamically outside of function
    tm_fill(deparse(substitute(fill_var)),
            style = "order",
            palette = "-inferno",
            legend.format = list(digits = 0),
            title = legend_title) +
    
    # Legend options
    tm_legend(position = c("left", "top"),
            bg.color = "white",
            bg.alpha = 0,
            width = 2, height = 10, title.size = 1.2,
            text.size = 1) +

    # Add in additional shape object for map boundaries  
    tm_shape(map_boundary_data) +
    
    # Specify polygon object with dynamic ID variable (for interactive maps)  
    tm_polygons(alpha = 0, 
              border.col = "white",
              lwd = 0.2, 
              id = boundary_id_var) +
    
    # Remove frame from final plot
    tm_layout(frame = FALSE) +
      
    scatter_plot_opts 
    
    # Return plot
    return(choropleth_map)
  
}
