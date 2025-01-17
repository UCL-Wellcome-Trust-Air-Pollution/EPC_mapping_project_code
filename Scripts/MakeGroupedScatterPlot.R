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
    
    summarise(perc = mean({{y_var}}, na.rm = TRUE) * 100,
              pop = sum({{size_var}}, na.rm = TRUE),
              x_var = mean({{x_var}}, na.rm = TRUE),
              .by = c({{group_var}},
                      {{colour_var}})) %>%
    
    # Arrange by 'size_var' to ensure smaller bubbles appear in front
    arrange(desc(pop)) %>%
    
    # Call ggplot
    ggplot() +
    
    # Add scatter points
    geom_point(aes(x = x_var,
                   y = perc,
                   colour = {{colour_var}},
                   size = pop),
               alpha = 0.7) +
    
    scale_size_continuous(labels = label_comma()) +
    
    scatter_plot_opts +
    
    theme(legend.position = legend_position)
  
  return(scatter_plot)
  
}