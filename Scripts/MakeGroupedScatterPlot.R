# Name of script: MakeGroupedScatterPlot
# Description:  Defines function to produce scatter plot of key variables by grouping variables
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 02-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 02-09-2024
# Update notes: Updated code to modularise into separate scripts

# Comments ---------------------------------------------------------------------

# Define function to produce scatter plot by group variable --------------------

make_grouped_scatter_plot <- function(data, 
                                      x_var, 
                                      y_var, 
                                      group_var, 
                                      colour_var, 
                                      size_var,
                                      legend_position){
  
  scatter_plot <- data %>%
    
    # Call ggplot
    ggplot() +
    
    # Add scatter points
    geom_point(aes(x = {{x_var}},
                   y = {{y_var}},
                   colour = {{colour_var}},
                   size = {{size_var}}),
               alpha = 0.7) +
    
    scale_size_continuous(labels = label_comma()) +
    
    scale_colour_manual(values = cbbPalette) +
    
    scatter_plot_opts +
    
    guides(colour = guide_legend(override.aes = list(size = 2))) +
    
    theme(legend.position = legend_position)
  
  return(scatter_plot)
  
}