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
                                 source_list){
  
  data_openair <- data_openair %>%
    
    filter(source %in% {{source_list}}) %>%
    
    filter(season %in% c("Summer",
                            "Winter")) %>%
    
    filter(day %in% {{days}}) %>%
    
    filter(grepl({{site_type}}, site_type)) %>%
    
    summarise("{{y_var}}" := mean({{y_var}}, na.rm = TRUE),
              "{{x_var}}" := mean({{x_var}}, na.rm = TRUE),
              
              .by = c(code, 
                      season))
  
  data_openair %>%
    
    ggplot(aes(x = {{x_var}},
               y = {{y_var}},
               colour = season)) +
    
    geom_point() +
    
    geom_smooth(method = lm,
                se = F) +
    
    stat_cor(method = "pearson",
             aes(label = after_stat(r.label))
             ) +
    
    scatter_plot_opts +
    
    theme(axis.title.y = element_text(angle=90),
          legend.title = element_blank(),
          legend.text = element_text(size = 12))
  
}