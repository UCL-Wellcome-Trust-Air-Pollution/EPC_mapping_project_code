# Name of script: MakeScatterPlotOpenair
# Description:  Defines function to make scatter plot with merged openair data
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 15-01-2025
# Latest update by: Calum Kennedy
# Latest update on: 20-01-2025
# Update notes: 

# Define function to make scatter plot with merged openair data ----------------

make_scatter_plot_openair <- function(data_openair,
                                 x_var,
                                 y_var,
                                 days,
                                 site_type,
                                 source_list,
                                 correlation_method,
                                 bootstrap_method,
                                 n_rep,
                                 conf_int){
  
  data_openair_for_plot <- data_openair %>%
    
    # Filter specified sources
    filter(source %in% {{source_list}}) %>%
    
    # Filter summer and winter seasons only
    filter(season %in% c("Summer",
                            "Winter")) %>%
    
    # Filter relevant days of week
    filter(day %in% {{days}}) %>%
    
    # Filter site type of interest using string
    filter(grepl({{site_type}}, site_type)) %>%
    
    # Summarise x_var and y_var by monitor code and season
    summarise("y_var" = mean({{y_var}}, na.rm = TRUE),
              "x_var" = mean({{x_var}}, na.rm = TRUE),
              
              .by = c(code, 
                      season)) %>%
    
    # Filter missing x_var and y_var values
    filter(!is.nan(y_var) & !is.nan(x_var))
  
  # Get vector of seasons to pass to lapply
  seasons <- c("Winter", 
               "Summer")
  
  # Get upper and lower 95% confidence bands for Spearman correlation
  list_conf_int <- lapply(seasons, function(p) get_bootstrap_ci(data_openair_for_plot,
                               p,
                               x_var = "x_var",
                               y_var = "y_var",
                               boot_func = get_corr,
                               n_rep = n_rep,
                               conf_int = conf_int,
                               correlation_method = correlation_method,
                               bootstrap_method = bootstrap_method))
  
  # Set names for conf_int list elements
  names(list_conf_int) <- seasons
  
  # Get confidence interval for difference between two correlation coefs
  corr_diff_boot <- boot(data_openair_for_plot, 
                         statistic = get_corr_diff, 
                         R = n_rep, 
                         x_var = "x_var", 
                         y_var = "y_var",
                         season_var = "season",
                         correlation_method = correlation_method)
  
  # Get 95% CI using method specified in 'method'
  corr_diff_boot_ci <- boot.ci(corr_diff_boot, 
                          conf = conf_int, 
                          type = bootstrap_method)
  
  # Get central estimate for correlation coefficient
  diff_correlation_coefficient <- round(corr_diff_boot_ci$t0, digits = 2)
  
  # Get lower confidence band ((length - 1)th element of vector)
  diff_lower_bound <- round(corr_diff_boot_ci[[4]][length(corr_diff_boot_ci[[4]]) - 1], digits = 2)
  
  # Get upper confidence band ((length)th element of vector)
  diff_upper_bound <- round(corr_diff_boot_ci[[4]][length(corr_diff_boot_ci[[4]])], digits = 2)
  
  # Get stats text to annotate plot
  plot_label_winter <- paste("Winter: R = ", 
                      list_conf_int[["Winter"]][["correlation_coefficient"]], 
                      ", 95%CI = [", list_conf_int[["Winter"]][["lower_bound"]],
                      ", ",
                      list_conf_int[["Winter"]][["upper_bound"]], "]",
                      sep = "")
  
  plot_label_summer <- paste("Summer: R = ", 
                             list_conf_int[["Summer"]][["correlation_coefficient"]], 
                             ", 95%CI = [", list_conf_int[["Summer"]][["lower_bound"]],
                             ", ",
                             list_conf_int[["Summer"]][["upper_bound"]], "]",
                             sep = "")
  
  # Make plot label for difference
  plot_label_diff <- paste("Difference: R = ",
                           diff_correlation_coefficient,
                           ", 95%CI = [", diff_lower_bound,
                           ", ",
                           diff_upper_bound, "]",
                           sep = "")
  
  # Combine text into single plot label
  plot_label <- paste(plot_label_winter,
                      plot_label_summer,
                      plot_label_diff,
                      sep = "\n")
  
  # Produce scatter plot
  data_openair_for_plot %>%
    
    # Main aesthetics
    ggplot(aes(x = x_var,
               y = y_var,
               colour = season)) +
    
    geom_point() +
    
    # Aesthetic options
    scatter_plot_opts +
    
    # Custom discrete palette
    scale_colour_manual(values = cbbPalette) +
    
    annotate("text",
             x = min(data_openair_for_plot[["x_var"]]) - 0.1 * diff(range(data_openair_for_plot[["x_var"]])),
             y = max(data_openair_for_plot[["y_var"]]) + 0.15 * diff(range(data_openair_for_plot[["y_var"]])),
             label = plot_label,
             hjust = 0,
             vjust = 1,
             colour = "black",
             size = 2.5) +
    
    theme(axis.title.y = element_text(angle = 90),
          legend.title = element_blank(),
          legend.text = element_text(size = 12))
  
}