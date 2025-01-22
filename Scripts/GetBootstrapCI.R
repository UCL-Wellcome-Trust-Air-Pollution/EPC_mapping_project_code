# Name of script: GetBootstrapCI
# Description:  Defines function to get 95% bootstrap confidence interval from arbitary dataset
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 21-01-2025
# Latest update by: Calum Kennedy
# Latest update on: 21-01-2025
# Update notes: 

# Define function to get bootstrap confidence interval -------------------------

get_bootstrap_ci <- function(data, 
                             x_var, 
                             y_var, 
                             season, 
                             boot_func, 
                             n_rep, 
                             conf_int, 
                             correlation_method,
                             bootstrap_method){
  
  # Set seed for reproducibility
  set.seed(123)
  
  # Filter by season to calculate bootstrap CI separately
  data_for_boot <- data %>%
    
    filter(season == {{season}})
  
  # Get vector of correlation coefficients from bootstrapped samples
  corr_boot <- boot(data_for_boot, 
                    statistic = boot_func, 
                    R = n_rep, 
                    x_var = x_var, 
                    y_var = y_var,
                    correlation_method = correlation_method) 
  
  # Get 95% CI using method specified in 'method'
  corr_boot_ci <- boot.ci(corr_boot, 
                          conf = conf_int, 
                          type = bootstrap_method)
  
  # Get central estimate for correlation coefficient
  correlation_coefficient <- round(corr_boot_ci$t0, digits = 2)
  
  # Get lower confidence band ((length - 1)th element of vector)
  lower_bound <- round(corr_boot_ci[[4]][length(corr_boot_ci[[4]]) - 1], digits = 2)
                      
  # Get upper confidence band ((length)th element of vector)
  upper_bound <- round(corr_boot_ci[[4]][length(corr_boot_ci[[4]])], digits = 2)
  
  # Combine into single vector
  output <- c("correlation_coefficient" = correlation_coefficient,
                "lower_bound" = lower_bound,
                "upper_bound" = upper_bound)
  
  # Return confidence interval
  return(output) 

}