# Created by use_targets()

# Load packages required to define the pipeline
library(targets)
library(tarchetypes)
library(tidylog)
library(here)
library(ggplot2)
library(viridis)

# Set options to prefer tidylog if conflicts 

# Set target options:
tar_option_set(
  
  packages = c("here",
               "arrow",
               "dplyr",
               "stringr",
               "httr2",
               "data.table",
               "duckdb",
               "janitor",
               "lubridate",
               "papeR",
               "gtsummary",
               "gt",
               "vroom",
               "readxl",
               "readODS",
               "sf",
               "ggplot2",
               "tidylog",
               "conflicted",
               "quarto",
               "qs",
               "extrafont",
               "viridis",
               "patchwork",
               "tidyr",
               "openair"),
  format = "qs",
  memory = "transient",
  garbage_collection = TRUE
)

# Run the R scripts with custom functions:
tar_source(here::here("Scripts/functions.R"))
tar_source(here::here("Scripts/LoadEnv.R"))

# Set list of targets
list(
  
  # Generate datasets ----------------------------------------------------------
  
  tar_target(data_epc_cleaned,
             clean_data_epc("data_epc.duckdb"),
             format = "parquet"),

  tar_target(data_uprn_sca_lookup, make_uprn_sca_lookup(path_stat_geo_files = "Data/raw/geo_files",
                                                        sca_path_eng = here("Data/raw/sca_data/Smoke_Control_Area_Boundaries_and_Exemptions.shp"),
                                                        sca_path_wal = here("Data/raw/sca_data/final_wales_sca.shp"),
                                                        long_var = "gridgb1e",
                                                        lat_var = "gridgb1n"),
             format = "parquet"),
  
  tar_target(data_os, get_os_data(here("Data/raw/os_data/ID32_Class_records.csv"))),
  
  tar_target(data_housing_type_os_epc, make_data_housing_type_os_epc(data_os,
                                                                     data_epc_cleaned)),
  
  tar_target(data_housing_type_census, make_data_housing_type_census(path_data_housing_type_census = here("Data/raw/census_data/TS044-2021-4-filtered-2024-10-15T15_26_58Z.csv"),
                                                                     path_region = "Data/raw/lsoa_data/Ward_to_Local_Authority_District_to_County_to_Region_to_Country_dec22.csv",
                                                                     path_ward = "Data/raw/lsoa_data/LSOA_(2021)_to_Ward_to_Lower_Tier_Local_Authority_(May_2022)_Lookup_for_England_and_Wales.csv")),

  tar_target(data_epc_cleaned_covars, merge_data_epc_cleaned_covars(data = data_epc_cleaned,
                                                                    data_uprn_sca_lookup = data_uprn_sca_lookup,
                                                                    path_lsoa_size = "Data/raw/lsoa_data/SAM_LSOA_DEC_2021_EW_in_KM.csv",
                                                                    path_imd_eng = "Data/raw/lsoa_data/File_5_-_IoD2019_Scores.xlsx",
                                                                    path_imd_wales = "Data/raw/lsoa_data/wimd-2019-index-and-domain-scores-by-small-area.ods",
                                                                    path_lsoa11_lsoa21_lookup = "Data/raw/lsoa_data/LSOA_(2011)_to_LSOA_(2021)_to_Local_Authority_District_(2022)_Best_Fit_Lookup_for_EW_(V2).csv",
                                                                    path_ethnicity = "Data/raw/lsoa_data/TS021-2021-3-filtered-2023-10-02T10_09_04Z.csv",
                                                                    path_region = "Data/raw/lsoa_data/Ward_to_Local_Authority_District_to_County_to_Region_to_Country_dec22.csv",
                                                                    path_ward = "Data/raw/lsoa_data/LSOA_(2021)_to_Ward_to_Lower_Tier_Local_Authority_(May_2022)_Lookup_for_England_and_Wales.csv",
                                                                    path_urban_rural = "Data/raw/lsoa_data/Rural_Urban_Classification_(2011)_of_Lower_Layer_Super_Output_Areas_in_England_and_Wales.csv"),
             format = "parquet"),
  
  tar_target(data_epc_coverage_lsoa_to_map, prepare_data_to_map(fill_data = make_data_epc_coverage(data_epc_cleaned,
                                                            data_os,
                                                            data_uprn_sca_lookup,
                                                            lsoa21cd),
                                                            shapefile_data = lsoa_boundaries,
                                                            join_var = "lsoa21cd")),

  tar_target(data_epc_lsoa_cross_section, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                                   data_housing_type_census = data_housing_type_census,
                                                                   lsoa_var = "lsoa21cd",
                                                                   geo_level_var = "lsoa21cd",
                                                                   housing_type_var = "property_type_census",
                                                                   n_cutoff_conc_pred = 20,
                                                                   group_vars = c("lsoa21cd",
                                                                                  "rgn22nm"),
                                                                   most_recent_only = TRUE),
             format = "parquet"),

  tar_target(data_epc_lsoa_by_year, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                               data_housing_type_census = data_housing_type_census,
                                                               lsoa_var = "lsoa21cd",
                                                               geo_level_var = "lsoa21cd",
                                                               housing_type_var = "property_type_census",
                                                               n_cutoff_conc_pred = 20,
                                                               group_vars = c("lsoa21cd",
                                                                              "lsoa21nm",
                                                                              "rgn22nm",
                                                                              "year"),
                                                               most_recent_only = FALSE),
             format = "parquet"),

  tar_target(data_epc_la_cross_section, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                                   data_housing_type_census = data_housing_type_census,
                                                                   lsoa_var = "lsoa21cd",
                                                                   geo_level_var = "lad22cd",
                                                                   housing_type_var = "property_type_census",
                                                                   n_cutoff_conc_pred = 20,
                                                                   group_vars = c("lad22cd",
                                                                                  "rgn22nm"),
                                                                   most_recent_only = TRUE),
             format = "parquet"),

  tar_target(data_epc_la_by_year, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                             data_housing_type_census = data_housing_type_census,
                                                             lsoa_var = "lsoa21cd",
                                                             geo_level_var = "lad22cd",
                                                             housing_type_var = "property_type_census",
                                                             n_cutoff_conc_pred = 20,
                                                             group_vars = c("lad22cd",
                                                                            "lad22nm",
                                                                            "rgn22nm",
                                                                            "year"),
                                                             most_recent_only = FALSE),
             format = "parquet"),

  tar_target(data_epc_ward_cross_section, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                                     data_housing_type_census = data_housing_type_census,
                                                                     lsoa_var = "lsoa21cd",
                                                                     geo_level_var = "wd22cd",
                                                                     housing_type_var = "property_type_census",
                                                                     n_cutoff_conc_pred = 20,
                                                                     group_vars = c("wd22cd",
                                                                                    "rgn22nm"),
                                                                     most_recent_only = TRUE),
             format = "parquet"),

  tar_target(data_epc_ward_by_year, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                               data_housing_type_census = data_housing_type_census,
                                                               lsoa_var = "lsoa21cd",
                                                               geo_level_var = "wd22cd",
                                                               housing_type_var = "property_type_census",
                                                               n_cutoff_conc_pred = 20,
                                                               group_vars = c("wd22cd",
                                                                              "wd22nm",
                                                                              "rgn22nm",
                                                                              "year"),
                                                               most_recent_only = FALSE),
             format = "parquet"),
  
  tar_target(data_epc_lsoa_housing_type, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                               data_housing_type_census = data_housing_type_census,
                                                               lsoa_var = "lsoa21cd",
                                                               geo_level_var = "lsoa21cd",
                                                               housing_type_var = "property_type_census",
                                                               n_cutoff_conc_pred = 20,
                                                               group_vars = c("lsoa21cd",
                                                                              "property_type_census",
                                                                              "rgn22nm"),
                                                               most_recent_only = TRUE),
             format = "parquet"),
  
  tar_target(lsoa_boundaries, get_shapefile(shapefile_path = here("Data/raw/map_boundary_data/LSOA_2021_EW_BFC_V10.shp"),
                                            geography_var = lsoa21cd)),
  
  tar_target(ward_boundaries, get_shapefile(shapefile_path = here("Data/raw/map_boundary_data/WD_DEC_22_GB_BFC.shp"),
                                            geography_var = wd22cd)),
  
  tar_target(la_boundaries, get_shapefile(shapefile_path = here("Data/raw/map_boundary_data/LAD_DEC_2022_UK_BFC_V2.shp"),
                                          geography_var = lad22cd)),

  tar_target(data_epc_lsoa_cross_section_to_map, prepare_data_to_map(fill_data = data_epc_lsoa_cross_section,
                                                                     shapefile_data = lsoa_boundaries,
                                                                     join_var = "lsoa21cd")),

  tar_target(data_epc_la_cross_section_to_map, prepare_data_to_map(fill_data = data_epc_la_cross_section,
                                                                   shapefile_data = la_boundaries,
                                                                     join_var = "lad22cd")),

  tar_target(data_epc_ward_cross_section_to_map, prepare_data_to_map(data_epc_ward_cross_section,
                                                                     shapefile_data = ward_boundaries,
                                                                     join_var = "wd22cd")),
  
  tar_target(data_openair, get_openair_data(source_list = c("aurn",
                                                            "aqe",
                                                            "waqn",
                                                            "local"),
                                            year_list = c(2021),
                                            frequency = "hourly",
                                            pollutant_list = "all",
                                            month_list = c(1, 2))),
  
  tar_target(data_openair_epc_cleaned, merge_openair_epc_data(data_openair = data_openair,
                                                              data_epc = data_epc_cleaned_covars,
                                                              long_var_epc = "long",
                                                              lat_var_epc = "lat",
                                                              buffer_radius = 500)),
  
  # Make figures ---------------------------------------------------------------

  tar_target(scatter_plot_pc_wood_imd, make_grouped_scatter_plot(data = data_epc_cleaned_covars,
                                                                 x_var = imd_score,
                                                                 y_var = any_wood_h,
                                                                 group_var = imd_decile,
                                                                 colour_var = rgn22nm,
                                                                 size_var = num_people,
                                                                 legend_position = "bottom") + 
               labs(colour = NULL,
                    x = "Mean IMD score",
                    y = "Wood fuel (%)") +
    
    guides(size = guide_legend(title = "Population")) +
      
      ggtitle("A")),

  tar_target(scatter_plot_pc_wood_white_eth, make_grouped_scatter_plot(data = data_epc_cleaned_covars,
                                                                 x_var = white_pct,
                                                                 y_var = any_wood_h,
                                                                 group_var = imd_decile,
                                                                 colour_var = rgn22nm,
                                                                 size_var = num_people,
                                                                 legend_position = "bottom") + 
               labs(colour = NULL,
                    x = "White ethnicity (%)",
                    y = NULL) +
               
               guides(size = guide_legend(title = "Population")) +
               
               ggtitle("B")),
  
  tar_target(scatter_wood_conc_vs_predicted_lsoa, (data_epc_lsoa_cross_section %>%
               
               ggplot(aes(x = wood_conc,
                          y = wood_conc_pred)) +
                 
                 ggtitle("A") +
               
               geom_point(alpha = 0.1,
                          size = 0.5) +
               
               scatter_plot_opts +
               
               geom_abline(alpha = 0.2) +
               
               labs(x = "Estimated (using EPCs)",
                    y = "Predicted\n(Census)"))),
  
  tar_target(scatter_wood_perc_h_vs_predicted_lsoa, (data_epc_lsoa_cross_section %>%
                                                     
                                                     ggplot(aes(x = wood_perc_h,
                                                                y = wood_perc_h_predicted)) +
                                                       
                                                       ggtitle("B") +
                                                     
                                                     geom_point(alpha = 0.1,
                                                                size = 0.5) +
                                                     
                                                     scatter_plot_opts +
                                                     
                                                     geom_abline(alpha = 0.2) +
                                                     
                                                     labs(x = "Estimated (using EPCs)",
                                                          y = ""))),
  
  # Prevalence maps

  tar_target(choropleth_map_wood_pc_lsoa, make_choropleth_map(fill_data = data_epc_lsoa_cross_section_to_map,
                                                 fill_var = wood_perc_h,
                                                 filter_low_n = TRUE,
                                                 n_var = epc,
                                                 n_threshold = 10,
                                                 boundary_data = la_boundaries,
                                                 fill_palette = "inferno",
                                                 scale_lower_lim = 0,
                                                 scale_upper_lim = 100,
                                                 winsorise = FALSE,
                                                 lower_perc = NULL,
                                                 upper_perc = NULL,
                                                 legend_title = "Percentage",
                                                 legend_position = "inside") +
               ggtitle("A")),
  
  tar_target(choropleth_map_sfa_pc_lsoa, make_choropleth_map(fill_data = data_epc_lsoa_cross_section_to_map,
                                                              fill_var = sfa_perc_h,
                                                              filter_low_n = TRUE,
                                                              n_var = epc,
                                                              n_threshold = 10,
                                                              boundary_data = la_boundaries,
                                                              fill_palette = "inferno",
                                                              scale_lower_lim = 0,
                                                              scale_upper_lim = 100,
                                                              winsorise = FALSE,
                                                              lower_perc = NULL,
                                                              upper_perc = NULL,
                                                              legend_title = "Percentage",
                                                              legend_position = "inside") +
               ggtitle("A")),

  tar_target(choropleth_map_wood_pc_lsoa_london, make_choropleth_map(fill_data = data_epc_lsoa_cross_section_to_map[data_epc_lsoa_cross_section_to_map$rgn22nm == "London",],
                                                              fill_var = wood_perc_h,
                                                              filter_low_n = TRUE,
                                                              n_var = epc,
                                                              n_threshold = 10,
                                                              boundary_data = la_boundaries[str_sub(la_boundaries$lad22cd, 1, 3) == "E09",],
                                                              fill_palette = "inferno",
                                                              scale_lower_lim = NULL,
                                                              scale_upper_lim = NULL,
                                                              winsorise = FALSE,
                                                              lower_perc = NULL,
                                                              upper_perc = NULL,
                                                              legend_title = "Percentage",
                                                              legend_position = "bottom") +
               ggtitle("A")),
  
  # Predicted concentration maps
  
  tar_target(choropleth_map_wood_conc_pred_lsoa, make_choropleth_map(fill_data = data_epc_lsoa_cross_section_to_map,
                                                                            fill_var = wood_conc_pred,
                                                                            filter_low_n = TRUE,
                                                                            n_var = epc,
                                                                            n_threshold = 10,
                                                                            boundary_data = la_boundaries,
                                                                            fill_palette = "inferno",
                                                                            scale_lower_lim = NULL,
                                                                            scale_upper_lim = NULL,
                                                                            winsorise = TRUE,
                                                                            lower_perc = 0.05,
                                                                            upper_perc = 0.95,
                                                                            legend_title = "Concentration\nper km2",
                                                                     legend_position = "inside") +
               ggtitle("B")),

  tar_target(choropleth_map_wood_conc_pred_lsoa_london, make_choropleth_map(fill_data = data_epc_lsoa_cross_section_to_map[data_epc_lsoa_cross_section_to_map$rgn22nm == "London",],
                                                                     fill_var = wood_conc_pred,
                                                                     filter_low_n = TRUE,
                                                                     n_var = epc,
                                                                     n_threshold = 10,
                                                                     boundary_data = la_boundaries[str_sub(la_boundaries$lad22cd, 1, 3) == "E09",],
                                                                     fill_palette = "inferno",
                                                                     scale_lower_lim = NULL,
                                                                     scale_upper_lim = NULL,
                                                                     winsorise = TRUE,
                                                                     lower_perc = 0.05,
                                                                     upper_perc = 0.95,
                                                                     legend_title = "Concentration\nper km2",
                                                                     legend_position = "bottom") +
               ggtitle("B")),
  
  tar_target(choropleth_map_sfa_conc_pred_lsoa, make_choropleth_map(fill_data = data_epc_lsoa_cross_section_to_map,
                                                                     fill_var = sfa_conc_pred,
                                                                     filter_low_n = TRUE,
                                                                     n_var = epc,
                                                                     n_threshold = 10,
                                                                     boundary_data = la_boundaries,
                                                                     fill_palette = "inferno",
                                                                     scale_lower_lim = NULL,
                                                                     scale_upper_lim = NULL,
                                                                     winsorise = TRUE,
                                                                     lower_perc = 0.05,
                                                                     upper_perc = 0.95,
                                                                     legend_title = "Concentration\nper km2",
                                                                     legend_position = "inside") +
               ggtitle("B")),
  
  # Facet wraps (manual for now)
  
  tar_target(facet_wood_pc_imd_score_region, (data_epc_cleaned_covars %>% 
               
               # Change region vars for formatting plot
               mutate(rgn22nm = case_when(rgn22nm == "Yorkshire and The Humber" ~ "Yorkshire and\nThe Humber",
                                          .default = rgn22nm)) %>%
               
               # Generate percentage of WF heat sources and mean IMD score by LSOA
               # We are measuring prevalence so restrict to houses only
               summarise(wood_perc = mean(any_wood_h, na.rm = TRUE) * 100, imd_score = mean(imd_score, na.rm = TRUE), .by = c(lsoa21cd, rgn22nm)) %>% 
               
               # Make plot
               ggplot(aes(x = imd_score, y = wood_perc)) + 
               
               geom_point(alpha = 0.2,
                          size = 0.1) + 
               
               facet_wrap(~rgn22nm) + 
               
               # Set plot options
               scatter_plot_opts +
               
               labs(x = "IMD Score",
                    y = "WF heat\nsource (%)") +
               
               theme(strip.text = element_text(size = 8))) %>%
               
               ggsave("Output/Figures/facet_wood_pc_imd_score_region.png", ., height = 5, width = 8, dpi = 700),
             format = "file"),
  
  tar_target(facet_wood_pc_white_pct_region, (data_epc_cleaned_covars %>% 
               
               # Change region vars for formatting plot
               mutate(rgn22nm = case_when(rgn22nm == "Yorkshire and The Humber" ~ "Yorkshire and\nThe Humber",
                                          .default = rgn22nm)) %>%
               
               # Generate percentage of WF heat sources and mean white percentage by LSOA
               # We are measuring prevalence so restrict to houses only
               summarise(wood_perc = mean(any_wood_h, na.rm = TRUE) * 100, 
                         white_pct = mean(white_pct, na.rm = TRUE), 
                         .by = c(lsoa21cd, rgn22nm)) %>% 
               
               # Make scatter plot
               ggplot(aes(x = white_pct, 
                          y = wood_perc)) + 
               
                geom_point(alpha = 0.2,
                            size = 0.1) + 
               
                 # Facet by region var
                facet_wrap(~rgn22nm) + 
               
                # Set plot options
                scatter_plot_opts +
               
                labs(x = "White ethnicity (%)",
                      y = "WF heat\nsource (%)") +
               
                theme(strip.text = element_text(size = 8))) %>%
               
               ggsave("Output/Figures/facet_wood_pc_white_pct_region.png", ., height = 5, width = 8, dpi = 700),
             format = "file"),
  
  tar_target(facet_wood_pc_imd_score_region_urban, (data_epc_cleaned_covars %>% 
                                                
                                                # Change region vars for formatting plot
                                                mutate(rgn22nm = case_when(rgn22nm == "Yorkshire and The Humber" ~ "Yorkshire and\nThe Humber",
                                                                           .default = rgn22nm)) %>%
                                                  
                                                  # Filter only urban areas
                                                  filter(urban == 1) %>%
                                                
                                                # Generate percentage of WF heat sources and mean IMD score by LSOA
                                                # We are measuring prevalence so restrict to houses only
                                                summarise(wood_perc = mean(any_wood_h, na.rm = TRUE) * 100, imd_score = mean(imd_score, na.rm = TRUE), .by = c(lsoa21cd, rgn22nm)) %>% 
                                                
                                                # Make plot
                                                ggplot(aes(x = imd_score, y = wood_perc)) + 
                                                
                                                geom_point(alpha = 0.2,
                                                           size = 0.1) + 
                                                
                                                facet_wrap(~rgn22nm) + 
                                                
                                                # Set plot options
                                                scatter_plot_opts +
                                                
                                                labs(x = "IMD Score",
                                                     y = "WF heat\nsource (%)") +
                                                
                                                theme(strip.text = element_text(size = 8))) %>%
               
               ggsave("Output/Figures/facet_wood_pc_imd_score_region_urban.png", ., height = 5, width = 8, dpi = 700),
             format = "file"),
  
  tar_target(facet_wood_pc_white_pct_region_urban, (data_epc_cleaned_covars %>% 
                                                
                                                # Change region vars for formatting plot
                                                mutate(rgn22nm = case_when(rgn22nm == "Yorkshire and The Humber" ~ "Yorkshire and\nThe Humber",
                                                                           .default = rgn22nm)) %>%
                                                  
                                                  # Filter urban areas only
                                                  filter(urban == 1) %>%
                                                
                                                # Generate percentage of WF heat sources and mean white percentage by LSOA
                                                # We are measuring prevalence so restrict to houses only
                                                summarise(wood_perc = mean(any_wood_h, na.rm = TRUE) * 100, 
                                                          white_pct = mean(white_pct, na.rm = TRUE), 
                                                          .by = c(lsoa21cd, rgn22nm)) %>% 
                                                
                                                # Make scatter plot
                                                ggplot(aes(x = white_pct, 
                                                           y = wood_perc)) + 
                                                
                                                geom_point(alpha = 0.2,
                                                           size = 0.1) + 
                                                
                                                # Facet by region var
                                                facet_wrap(~rgn22nm) + 
                                                
                                                # Set plot options
                                                scatter_plot_opts +
                                                
                                                labs(x = "White ethnicity (%)",
                                                     y = "WF heat\nsource (%)") +
                                                
                                                theme(strip.text = element_text(size = 8))) %>%
               
               ggsave("Output/Figures/facet_wood_pc_white_pct_region_urban.png", ., height = 5, width = 8, dpi = 700),
             format = "file"),
  
  tar_target(facet_wood_pc_property_type_region, (data_epc_cleaned_covars %>% 
               
               # Summarise WF prevalence by region, year, and housing type
               summarise(wood_perc = mean(any_wood_h, na.rm = TRUE) * 100, .by = c(year, property_type_census, rgn22nm)) %>% 
               
               # Filter Nan values (for flats, house type missing)
               filter(!is.nan(wood_perc)) %>% 
               
               # Change region name for plotting
               mutate(rgn22nm = case_when(rgn22nm == "Yorkshire and The Humber" ~ "Yorkshire and\nThe Humber", .default = rgn22nm)) %>% 
               
               # Make facet wrap
               ggplot() + 
               
               geom_line(aes(x = year, y = wood_perc, colour = property_type_census)) + 
               
               facet_wrap(~rgn22nm) + 
               
               scatter_plot_opts +
                 
                 labs(x = "",
                      y = "Wood fuel\nprevalence (%)",
                      colour = "Property type") +
                 
                 theme(legend.position = "inside",
                       legend.position.inside = c(0.7, 0.1))) %>%
               
               ggsave("Output/Figures/facet_wood_pc_property_type_region.png", ., height = 5, width = 8, dpi = 700),
             format = "file"),

  tar_target(choropleth_map_epc_coverage_lsoa, (make_choropleth_map(fill_data = data_epc_coverage_lsoa_to_map,
                                                                   fill_var = epc_coverage,
                                                                   n_var = NULL,
                                                                   n_threshold = NULL,
                                                                   boundary_data = la_boundaries,
                                                                   fill_palette = "inferno",
                                                                   scale_lower_lim = 0,
                                                                   scale_upper_lim = 100,
                                                                   winsorise = FALSE,
                                                                   lower_perc = NULL,
                                                                   upper_perc = NULL,
                                                                   legend_title = "Percentage",
                                                                   legend_position = "inside")) %>%
               
               ggsave("Output/Maps/choropleth_map_epc_coverage_lsoa.png", ., height = 5, width = 8, dpi = 700),
             format = "file"),
  
  # Patchwork plots
  tar_target(patchwork_choropleth_map_wood_pc_conc_pred_lsoa, (make_patchwork_plot(list = list(choropleth_map_wood_pc_lsoa,
                                                                                              choropleth_map_wood_conc_pred_lsoa),
                                                                                  guides = "keep",
                                                                                  ncol = 2)) %>%
               
               ggsave("Output/Maps/patchwork_choropleth_map_wood_pc_conc_pred_lsoa.png", ., dpi = 700, width = 8, height = 5),
             format = "file"),
  
  tar_target(patchwork_choropleth_map_sfa_pc_conc_pred_lsoa, (make_patchwork_plot(list = list(choropleth_map_sfa_pc_lsoa,
                                                                                               choropleth_map_sfa_conc_pred_lsoa),
                                                                                   guides = "keep",
                                                                                   ncol = 2)) %>%
               
               ggsave("Output/Maps/patchwork_choropleth_map_sfa_pc_conc_pred_lsoa.png", ., dpi = 700, width = 8, height = 5),
             format = "file"),
  
  tar_target(patchwork_choropleth_map_wood_pc_conc_pred_lsoa_london, (make_patchwork_plot(list = list(choropleth_map_wood_pc_lsoa_london,
                                                                                               choropleth_map_wood_conc_pred_lsoa_london),
                                                                                   guides = "keep",
                                                                                   ncol = 2)) %>%
               
               ggsave("Output/Maps/patchwork_choropleth_map_wood_pc_conc_pred_lsoa_london.png", ., dpi = 700, width = 8, height = 5),
             format = "file"),
  
  tar_target(patchwork_scatter_wood_pc_imd_white_eth, (make_patchwork_plot(list = list(scatter_plot_pc_wood_imd,
                                                                                      scatter_plot_pc_wood_white_eth),
                                                                           legend_position = "right",
                                                                          guides = "collect",
                                                                          ncol = 1)) %>%
               
               ggsave("Output/Figures/patchwork_scatter_wood_pc_imd_white_eth.png", ., dpi = 700, width = 8, height = 5),
             format = "file"),
  
  tar_target(patchwork_wood_conc_perc_h_pred_actual, (make_patchwork_plot(list = list(scatter_wood_conc_vs_predicted_lsoa,
                                                                                     scatter_wood_perc_h_vs_predicted_lsoa),
                                                                         legend_position = "right")) %>%
               
               ggsave("Output/Figures/patchwork_wood_conc_perc_h_pred_actual.png", ., dpi = 700, width = 8, height = 5),
             format = "file"),
  
  # Run logit model ------------------------------------------------------------
  
  tar_target(data_for_logit_model, prepare_data_for_logit_model(data = data_epc_cleaned_covars,
                                                                outcome_var = "any_wood_h",
                                                                predictor_vars = c("year",
                                                                                   "urban",
                                                                                   "property_type_census",
                                                                                   "tenure",
                                                                                   "sca_area",
                                                                                   "imd_score",
                                                                                   "white_pct"),
                                                                numeric_to_factor_vars = c("any_wood_h",
                                                                                           "urban",
                                                                                           "sca_area"),
                                                                most_recent_only = TRUE)),
  
  tar_target(logit_model, build_logit_model(data = data_for_logit_model,
                                            outcome_var = "any_wood_h",
                                            predictor_vars = c("year",
                                                               "urban",
                                                               "property_type_census",
                                                               "tenure",
                                                               "sca_area",
                                                               "imd_score",
                                                               "white_pct"))),
  
  tar_target(data_urban_for_logit_model, prepare_data_for_logit_model(data = data_epc_cleaned_covars[data_epc_cleaned_covars$urban == 1,],
                                                                outcome_var = "any_wood_h",
                                                                predictor_vars = c("year",
                                                                                   "property_type_census",
                                                                                   "tenure",
                                                                                   "sca_area",
                                                                                   "imd_score",
                                                                                   "white_pct"),
                                                                numeric_to_factor_vars = c("any_wood_h",
                                                                                           "sca_area"),
                                                                most_recent_only = TRUE)),
  
  tar_target(logit_model_urban, build_logit_model(data = data_urban_for_logit_model,
                                            outcome_var = "any_wood_h",
                                            predictor_vars = c("year",
                                                               "property_type_census",
                                                               "tenure",
                                                               "sca_area",
                                                               "imd_score",
                                                               "white_pct"))),

  tar_quarto(EPC_project_manuscript,
            "EPC_project_manuscript.qmd",
            quiet = FALSE)
)
