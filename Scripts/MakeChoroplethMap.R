# Name of script: MakeChoroplethMap2
# Description:  Defines function to produce choropleth map of UK given arbitrary dataset
# and geographical resolution using ggplot2 package
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 23-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 23-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# Defines function to produce choropleth map of UK at arbitrary geographical resolution, 
# given an arbitrary dataset using ggplot2 package

# Define map function ----------------------------------------------------------

make_choropleth_map <- function(fill_data,
                                fill_var,
                                filter_low_n = FALSE,
                                n_var = NULL,
                                n_threshold = NULL,
                                boundary_data,
                                fill_palette = "inferno",
                                scale_lower_lim = NULL,
                                scale_upper_lim = NULL,
                                winsorise = FALSE,
                                lower_perc = NULL,
                                upper_perc = NULL,
                                legend_title,
                                legend_position){
  
  # If 'n_var' is specified, filter data to plot based on number of obs higher than 'n_threshold'
  if(filter_low_n) fill_data <- fill_data %>% filter({{n_var}} > n_threshold)
  
  # If 'winsorise' is TRUE, winsorise upper and lower percentiles of fill variable (default is 5th and 95th percentile)
  if(winsorise) fill_data <- mutate(fill_data, "{{fill_var}}" := case_when({{fill_var}} > get_percentile({{fill_var}}, upper_perc) ~ get_percentile({{fill_var}}, upper_perc),
                                                                           {{fill_var}} < get_percentile({{fill_var}}, lower_perc) ~ get_percentile({{fill_var}}, lower_perc),
                                                                           .default = {{fill_var}}))
  
  
  choropleth_map <- ggplot(fill_data
                           ) +
    
    geom_sf(aes(fill = {{fill_var}}),
            colour = NA
            ) +
    
    scale_fill_viridis(option = fill_palette,
                       direction = -1,
                       limits = c(scale_lower_lim,
                                  scale_upper_lim)
    ) +
    
    theme_void() +
    
    theme(legend.title = element_text(size = 10),
          legend.text = element_text(size = 8),
          legend.justification.inside = c(1, 1),
          plot.title = element_text(face = "bold")) +
    
    guides(fill = guide_colourbar(position = legend_position,
                                  title = legend_title))
  
  return(choropleth_map)
  
}
