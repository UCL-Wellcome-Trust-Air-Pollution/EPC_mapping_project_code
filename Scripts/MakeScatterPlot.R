# Name of script: MakeScatterPlot.R
# Description:  Generic function to make a scatter plot (with group/facet vars if required) 
# data to merge with main EPC data
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 16-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 16-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# Defines function to generate scatter plot with options for facet/group vars

# Define function to produce scatter plot --------------------------------------

make_scatter_plot <- function(data, 
                              x_var, 
                              y_var, 
                              colour_var = NULL, 
                              facet_var = NULL,
                              size,
                              alpha){
  
  # Produce scatter plot
  data %>%
    
    # Main ggplot call
    ggplot(aes(x = {{x_var}},
               y = {{y_var}},
               colour = {{colour_var}})) +
    
    # Add geom point
    geom_point(size = size,
               alpha = alpha) +
    
    scatter_plot_opts
  
  # In future, can add custom colour palettes, etc

  
}