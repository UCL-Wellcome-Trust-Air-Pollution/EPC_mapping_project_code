# Name of script: MakeSummaryTable
# Description:  Defines function to make summary table for arbitrary dataset using {gtsummary}
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 09-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 09-09-2024
# Update notes: Updated code to modularise into separate scripts

# Comments ---------------------------------------------------------------------

# I have chosen to use {gtsummary} since it offers a lot of functionality

# Define function to produce summary table from arbitrary dataframe ------------

make_summary_table <- function(data, 
                               vars_to_summarise, 
                               group_var = NULL,
                               report_missing = NULL){
  
  # Error to catch incorrect specification of behaviour for missing variables
  if(!report_missing %in% c(TRUE,
                            FALSE)){
    stop("Error: Please set 'report_missing' to either TRUE or FALSE")
  }
  
  # Set behaviour with respect to missing values
  if(report_missing == TRUE) report_missing <- "always"
  if(report_missing == FALSE) report_missing <- "no"
  
  # Generate main summary table using {gtsummary}
  summary_table <- tbl_summary(data,
                               include = vars_to_summarise,
                               by = group_var,
                               missing = report_missing,
                               digits = all_continuous() ~ 0,
                               missing_text = "Missing") %>%
    
    # Add the n
    add_n() %>%
    
    # Format labels
    bold_labels()
  
  # If specify a grouping variable, add the aggregate totals as well
  if(!is.null(group_var)) summary_table <- summary_table %>% add_overall()
  
  # Return the summary table
  return(summary_table)
  
}