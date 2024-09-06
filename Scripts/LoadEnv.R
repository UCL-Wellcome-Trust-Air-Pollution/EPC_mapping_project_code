# Name of script: 0_LoadEnv
# Description:  Loads environment for extraction/cleaning of Eenergy Performance Certificate data 
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 12-08-2024
# Latest update by: Calum Kennedy
# Latest update on: 03-09-2024
# Update notes: Updated code to modularise into separate scripts

# Comments ---------------------------------------------------------------------

# Loads environment for analysis of EPC data
# Loads necessary packages
# Defines global options for output plots and figures

# Set options to prefer tidylog if conflicts 

for (f in getNamespaceExports("tidylog")) {
  conflicted::conflict_prefer(f, "tidylog", quiet = TRUE)
}

# Set global plot options ------------------------------------------------------

scatter_plot_opts <- list(scale_size(range = c(2, 10)),
                          scale_color_brewer(palette = "Paired", direction = -1),
                          theme(legend.position = "bottom",
                                legend.box = "vertical"))
