# Name of script: 7_MakeGroupedScatterPlot
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
                                      y_var_numerator, 
                                      y_var_denominator, 
                                      group_var, 
                                      colour_var, 
                                      size_var){
  
  scatter_plot <- data %>%
    
    # Group by grouping variable
    group_by({{group_var}}, {{colour_var}}) %>%
    
    summarise(perc = sum({{y_var_numerator}}, na.rm = TRUE) / sum({{y_var_denominator}}, na.rm = TRUE) * 100,
              pop = sum({{size_var}}, na.rm = TRUE),
              x_var = mean({{x_var}}, na.rm = TRUE)) %>%
    
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
    
    scatter_plot_opts
  
  return(scatter_plot)
  
}