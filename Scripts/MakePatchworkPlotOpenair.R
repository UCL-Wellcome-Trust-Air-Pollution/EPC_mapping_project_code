# Name of script: MakeScatterPlotOpenair
# Description:  Defines function to make patchwork from openair scatter plots
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 15-01-2025
# Latest update by: Calum Kennedy
# Latest update on: 20-01-2025
# Update notes: 

# Define function to make patchwork plot calling the 'make_scatter_plot_openair' 
# function with merged openair data --------------------------------------------

make_patchwork_plot_openair <- function(data_openair,
                                        x_var,
                                        pm2.5_var,
                                        pm2.5_diff_peak_var,
                                        x_lab,
                                        site_type,
                                        source_list,
                                        correlation_method,
                                        bootstrap_method,
                                        boot_func,
                                        n_rep,
                                        conf_int){
  
  # make scatter plot of x_var against average PM2.5 levels in summer and winter
  plot_avg_pm2.5 <- make_scatter_plot_openair(data_openair,
                                              x_var = {{x_var}},
                                              y_var = {{pm2.5_var}},
                                              days = c("Monday",
                                                       "Tuesday",
                                                       "Wednesday",
                                                       "Thursday",
                                                       "Friday",
                                                       "Saturday",
                                                       "Sunday"),
                                              {{site_type}},
                                              {{source_list}},
                                              correlation_method = correlation_method,
                                              bootstrap_method = bootstrap_method,
                                              boot_func = boot_func,
                                              n_rep = n_rep,
                                              conf_int = conf_int) +
    
    ggtitle("Average") +
    
    labs(x = x_lab,
         y = expression("Average PM"["2.5"]))
  
  # Make scatter plot of x_var against difference between peak vs. non-peak PM2.5 on weekdays
  plot_diff_peak_pm2.5_weekdays <- make_scatter_plot_openair(data_openair,
                                                             x_var = {{x_var}},
                                                             y_var = {{pm2.5_diff_peak_var}},
                                                             days = c("Monday",
                                                                      "Tuesday",
                                                                      "Wednesday",
                                                                      "Thursday",
                                                                      "Friday"),
                                                             {{site_type}},
                                                             {{source_list}},
                                                             correlation_method = correlation_method,
                                                             bootstrap_method = bootstrap_method,
                                                             boot_func = boot_func,
                                                             n_rep = n_rep,
                                                             conf_int = conf_int) +
    
    ggtitle("Weekday") +
    
    labs(x = x_lab,
         y = expression("Peak PM"[2.5] - "non-peak PM"[2.5]))
  
  # Make scatter plot of x_var against difference between peak vs. non-peak PM2.5 on weekdays
  plot_diff_peak_pm2.5_weekends <- make_scatter_plot_openair(data_openair,
                                                             x_var = {{x_var}},
                                                             y_var = {{pm2.5_diff_peak_var}},
                                                             days = c("Saturday",
                                                                      "Sunday"),
                                                             {{site_type}},
                                                             {{source_list}},
                                                             correlation_method = correlation_method,
                                                             bootstrap_method = bootstrap_method,
                                                             boot_func = boot_func,
                                                             n_rep = n_rep,
                                                             conf_int = conf_int) +
    
    ggtitle("Weekend") +
    
    labs(x = x_lab,
         y = expression("Peak PM"[2.5] - "non-peak PM"[2.5]))
  
  # Compile into patchwork plot
  patchwork_plot_openair <- plot_avg_pm2.5 + 
    plot_diff_peak_pm2.5_weekdays + 
    plot_diff_peak_pm2.5_weekends +
    
    # Set plot layout options
    plot_layout(ncol = 3,
                guides = "collect",
                axis_titles = "collect") &
    
    scatter_plot_opts &
    
    theme(legend.position = "bottom",
          axis.title.y=element_text(angle=90),
          legend.title = element_blank(),
          legend.text = element_text(size = 12))
  
}