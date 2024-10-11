# Created by use_targets()

# Load packages required to define the pipeline
library(targets)
library(tarchetypes)
library(tidylog)
library(here)
library(ggplot2)
library(viridis)
#library(future)
#library(future.callr)

#plan(callr)

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
               "RColorBrewer",
               "tmap",
               "tidylog",
               "conflicted",
               "quarto",
               "qs",
               "extrafont",
               "viridis",
               "osmdata",
               "OpenStreetMap",
               "patchwork"),
  format = "qs",
  memory = "transient",
  garbage_collection = TRUE
)

# Run the R scripts with custom functions:
tar_source(here::here("Scripts/functions.R"))
tar_source(here::here("Scripts/LoadEnv.R"))

# Set list of targets
list(
  
  tar_target(data_epc_cleaned,
             clean_data_epc("data_epc.duckdb"),
             format = "parquet"),

  tar_target(data_uprn_sca_lookup, make_uprn_sca_lookup(path_stat_geo_files = "Data/raw/geo_files",
                                                        sca_path_eng = here("Data/raw/sca_data/Smoke_Control_Area_Boundaries_and_Exemptions.shp"),
                                                        sca_path_wal = here("Data/raw/sca_data/final_wales_sca.shp"),
                                                        long_var = "gridgb1e",
                                                        lat_var = "gridgb1n"),
             format = "parquet"),

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

  tar_target(data_epc_lsoa_cross_section, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                                   lsoa_var = lsoa21cd,
                                                                   group_vars = c("lsoa21cd",
                                                                                  "rgn22nm"),
                                                                   most_recent_only = TRUE),
             format = "parquet"),

  tar_target(data_epc_lsoa_by_year, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                               lsoa_var = lsoa21cd,
                                                               group_vars = c("lsoa21cd",
                                                                              "lsoa21nm",
                                                                              "rgn22nm",
                                                                              "year"),
                                                               most_recent_only = FALSE),
             format = "parquet"),

  tar_target(data_epc_la_cross_section, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                                   lsoa_var = lsoa21cd,
                                                                   group_vars = c("lad22cd",
                                                                                  "rgn22nm"),
                                                                   most_recent_only = TRUE),
             format = "parquet"),

  tar_target(data_epc_la_by_year, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                             lsoa_var = lsoa21cd,
                                                             group_vars = c("lad22cd",
                                                                            "lad22nm",
                                                                            "rgn22nm",
                                                                            "year"),
                                                             most_recent_only = FALSE),
             format = "parquet"),

  tar_target(data_epc_ward_cross_section, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                                     lsoa_var = lsoa21cd,
                                                                     group_vars = c("wd22cd",
                                                                                    "rgn22nm"),
                                                                     most_recent_only = TRUE),
             format = "parquet"),

  tar_target(data_epc_ward_by_year, make_summary_data_by_group(data = data_epc_cleaned_covars,
                                                               lsoa_var = lsoa21cd,
                                                               group_vars = c("wd22cd",
                                                                              "wd22nm",
                                                                              "rgn22nm",
                                                                              "year"),
                                                               most_recent_only = FALSE),
             format = "parquet"),

  tar_target(data_epc_lsoa_cross_section_to_map, prepare_data_to_map(data_epc_lsoa_cross_section,
                                                               "lsoa21cd")),

  tar_target(data_epc_lsoa_by_year_to_map, prepare_data_to_map(data_epc_lsoa_by_year,
                                                               "lsoa21cd")),

  tar_target(data_epc_la_cross_section_to_map, prepare_data_to_map(data_epc_la_cross_section,
                                                                     "lad22cd")),

  tar_target(data_epc_la_by_year_to_map, prepare_data_to_map(data_epc_la_by_year,
                                                               "lad22cd")),

  tar_target(data_epc_ward_cross_section_to_map, prepare_data_to_map(data_epc_ward_cross_section,
                                                                     "wd22cd")),

  tar_target(data_epc_ward_by_year_to_map, prepare_data_to_map(data_epc_ward_by_year,
                                                               "wd22cd")),

  tar_target(data_epc_coverage_lsoa_to_map, prepare_data_to_map(make_data_epc_coverage(data_epc_cleaned_covars,
                                                                                       data_uprn_sca_lookup = data_uprn_sca_lookup,
                                                                                       geography = "lsoa21cd"),
                                                                "lsoa21cd")),

  tar_target(data_epc_coverage_ward_to_map, prepare_data_to_map(make_data_epc_coverage(data_epc_cleaned_covars,
                                                       data_uprn_sca_lookup = data_uprn_sca_lookup,
                                                       geography = "wd22cd"),
                                                       "wd22cd")),

  tar_target(lsoa_boundaries, get_mapping_boundaries("lsoa21cd")),

  tar_target(la_boundaries, get_mapping_boundaries("lad22cd")),

  tar_target(ward_boundaries, get_mapping_boundaries("wd22cd")),

  tar_target(scatter_plot_pc_wood_imd, make_grouped_scatter_plot(data = data_epc_lsoa_cross_section,
                                                                 x_var = imd_score,
                                                                 y_var_numerator = any_wood_h,
                                                                 y_var_denominator = epc_house_total,
                                                                 group_var = imd_decile,
                                                                 colour_var = rgn22nm,
                                                                 size_var = num_people)),

  tar_target(choropleth_map_wood_pc_lsoa, make_choropleth_map(fill_data = data_epc_lsoa_cross_section_to_map,
                                                 fill_var = wood_epc,
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
                                                 legend_title = "Percentage")),

  tar_target(choropleth_map_wood_pc_lsoa_london, make_choropleth_map(fill_data = data_epc_lsoa_cross_section_to_map[data_epc_lsoa_cross_section_to_map$rgn22nm == "London",],
                                                              fill_var = wood_epc,
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
                                                              legend_title = "Percentage")),

  tar_target(choropleth_map_wood_pc_lsoa_2009, make_choropleth_map(fill_data = data_epc_lsoa_by_year_to_map[data_epc_lsoa_by_year_to_map$year == 2009,],
                                                                   fill_var = wood_epc,
                                                                   filter_low_n = TRUE,
                                                                   n_var = epc,
                                                                   n_threshold = 10,
                                                                   boundary_data = la_boundaries,
                                                                   scale_lower_lim = 0,
                                                                   scale_upper_lim = 100,
                                                                   winsorise = FALSE,
                                                                   lower_perc = NULL,
                                                                   upper_perc = NULL,
                                                                   legend_title = "Percentage")),

  tar_target(choropleth_map_wood_pc_lsoa_2023, make_choropleth_map(fill_data = data_epc_lsoa_by_year_to_map[data_epc_lsoa_by_year_to_map$year == 2023,],
                                                                   fill_var = wood_epc,
                                                                   filter_low_n = TRUE,
                                                                   n_var = epc,
                                                                   n_threshold = 10,
                                                                   boundary_data = la_boundaries,
                                                                   scale_lower_lim = 0,
                                                                   scale_upper_lim = 100,
                                                                   winsorise = FALSE,
                                                                   lower_perc = NULL,
                                                                   upper_perc = NULL,
                                                                   legend_title = "Percentage")),

  tar_target(choropleth_map_wood_conc_lsoa_london, make_choropleth_map(fill_data = data_epc_lsoa_cross_section_to_map[data_epc_lsoa_cross_section_to_map$rgn22nm == "London",],
                                                                     fill_var = wood_conc,
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
                                                                     legend_title = "Concentration per km2")),

  tar_target(choropleth_map_wood_pc_ward, make_choropleth_map(fill_data = data_epc_ward_cross_section_to_map,
                                                              fill_var = wood_epc,
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
                                                              legend_title = "Percentage")),

  tar_target(choropleth_map_wood_pc_la, make_choropleth_map(fill_data = data_epc_la_cross_section_to_map,
                                                            fill_var = wood_epc,
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
                                                            legend_title = "Percentage")),

  tar_target(choropleth_map_epc_coverage_lsoa, make_choropleth_map(fill_data = data_epc_coverage_lsoa_to_map,
                                                                   fill_var = coverage_perc,
                                                                   n_var = NULL,
                                                                   n_threshold = NULL,
                                                                   boundary_data = la_boundaries,
                                                                   fill_palette = "inferno",
                                                                   scale_lower_lim = 0,
                                                                   scale_upper_lim = 100,
                                                                   winsorise = FALSE,
                                                                   lower_perc = NULL,
                                                                   upper_perc = NULL,
                                                                   legend_title = "Percentage")),

  tar_target(choropleth_map_epc_coverage_ward_london, make_choropleth_map(fill_data = data_epc_coverage_ward_to_map[data_epc_coverage_ward_to_map$rgn22nm == "London",],
                                                                          fill_var = coverage_perc,
                                                                          n_var = NULL,
                                                                          n_threshold = NULL,
                                                                          boundary_data = la_boundaries[str_sub(la_boundaries$lad22cd, 1, 3) == "E09",],
                                                                          fill_palette = "inferno",
                                                                          scale_lower_lim = 0,
                                                                          scale_upper_lim = 100,
                                                                          winsorise = FALSE,
                                                                          lower_perc = NULL,
                                                                          upper_perc = NULL,
                                                                          legend_title = "Percentage")),

  tar_target(scatter_plot_epc_coverage_pc_wood_lsoa, data_epc_coverage_lsoa_to_map %>%

               left_join(data_epc_lsoa_cross_section, by = "lsoa21cd") %>%

               make_scatter_plot(x_var = coverage_perc,
                                 y_var = wood_epc,
                                 colour_var = NULL,
                                 facet_var = NULL,
                                 size = 0.5,
                                 alpha = 0.5) +

               labs(x = "Percentage of UPRNs present in EPC data by LSOA",
                    y = "Percentage of homes with wood burning heat sources")),

  tar_target(line_plot_pm25_emissions_absolute, make_line_plot(get_air_pollution_data(
    data_path = "Data/raw/air_pollution_data/tables_for_emissions_by_source_1990_to_2022_rev.ods",
    sheet = "Table_2a_&_2b",
    data_range = "A3:AH20",
    colnames = TRUE),
    year,
    emissions,
    source)),

  tar_target(line_plot_pm25_emissions_perc, make_line_plot(get_air_pollution_data(
    data_path = "Data/raw/air_pollution_data/tables_for_emissions_by_source_1990_to_2022_rev.ods",
    sheet = "Table_2a_&_2b",
    data_range = "A26:AH41",
    colnames = TRUE),
    year,
    emissions,
    source)),

  tar_quarto(EPC_project_manuscript,
             "EPC_project_manuscript.qmd",
             quiet = FALSE)
)
