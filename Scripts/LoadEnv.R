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

# Set global plot options ------------------------------------------------------

# Scatter plot options
scatter_plot_opts <- list(
  
  # Main theme
  theme_bw(base_size = 12),
  
  # Theme customisation
  theme(
    # Title options
    plot.title = element_text(face = "bold"),
    
    # Panel options
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    
    # Legend options
    legend.box = "vertical",
    legend.title = element_text(face = "bold"),
    legend.text = element_text(size = 8),
    
    # Facet options
    strip.background = element_blank(),
    strip.text = element_text(face = "bold"),
    
    # Axis options
    axis.line = element_line(),
    axis.title.y=element_text(angle=0))
)

# Line plot options
line_plot_opts <- list(
  
  # Main theme
  theme_bw(base_size = 12),
  
  # Theme customisation
  theme(
    # Title options
    plot.title = element_text(face = "bold"),
                         
    # Panel options
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
     
    # Legend options
    legend.box = "vertical",
    legend.title = element_text(face = "bold"),
    legend.text = element_text(size = 8),
     
    # Facet options
    strip.background = element_blank(),
    strip.text = element_text(face = "bold"),
     
    # Axis options
    axis.line = element_line(),
    axis.title.y=element_text(angle=0)),
  
  # Colour options
  scale_colour_viridis(option = "inferno",
                       discrete = TRUE),
                       geom_line(size = 1))