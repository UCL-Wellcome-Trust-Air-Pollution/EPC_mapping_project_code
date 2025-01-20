make_scatter_plot_openair <- function(data_openair,
                                 x_var,
                                 y_var,
                                 days,
                                 site_type,
                                 sca_area,
                                 source_list){
  
  if(sca_area == "yes") data_openair <- data_openair %>% filter(sca_area == 1)
  if(sca_area == "no") data_openair <- data_openair %>% filter(sca_area == 0)
  
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