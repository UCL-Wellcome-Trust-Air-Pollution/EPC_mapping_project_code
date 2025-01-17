# Name of script: MakePatchworkPlot
# Description:  Defines function to produce patchwork for arbitrary plotting function
# defined on an arbitrary list of input variables
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 02-10-2024
# Latest update by: Calum Kennedy
# Latest update on: 02-10-2024

# Comments ---------------------------------------------------------------------

# Define function to produce patchwork of ggplot objects using 'reduce' --------

make_patchwork_plot <- function(list, 
                                legend_position = NULL,
                                ...){
  
  # Make patchwork object by applying `+` operator to list of objects
  patchwork <- Reduce(`+`, list) +
    
    # Set plot layout
    plot_layout(...) &
    
    # Optional legend position
    theme(legend.position = legend_position,
          legend.box = "vertical")
  
  return(patchwork)
  
}