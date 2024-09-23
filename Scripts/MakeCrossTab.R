# Name of script: MakeCrossTab
# Description:  Defines function to make cross tab for multiple categorical 
# variables in an arbitrary dataset using {gtsummary}
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 09-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 09-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# I have chosen to use {gtsummary} since it offers a lot of functionality

# Define function to produce cross table of two variables 
# from arbitrary dataframe -----------------------------------------------------

make_cross_tab <- function(data, 
                           most_recent_only,
                           row_var,
                           col_var,
                           name){
  
  # If most_recent_only is TRUE, subset data to most recent EPC
  if(most_recent_only == TRUE) data <- data %>% filter(most_recent == TRUE)
  
  # Generate cross tab
  cross_tab <- tbl_cross(data,
                         row_var,
                         col_var,
                         percent = "row",
                         missing_text = "Missing") %>%
    
    # Format bold labels
    bold_labels() %>%
    
    # Set as 'gt' object to export to HTML
    as_gt()
    
    # Save file to specified path
    gtsave(cross_tab, here(paste0("Output/Tables/", name, ".html")))
  
}