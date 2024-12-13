# Name of script: MakeUPRNSCALookup.R
# Description:  Loads statistical geographies and SCA data to merge with main EPC data
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 02-10-2024
# Latest update by: Calum Kennedy
# Latest update on: 02-10-2024
# Update notes: 

# Comments ---------------------------------------------------------------------


# Define function to merge statistical geographies with SCA data ---------------

make_uprn_sca_lookup <- function(path_stat_geo_files,
                                 sca_path_eng,
                                 sca_path_wal,
                                 long_var,
                                 lat_var){
  
  # Get UPRN lookup datasets and merge using 'merge statistical geographies' function
  data_geo_uprn <- read_parquet(path_stat_geo_files)
  
  # Add in SCA status using 'merge_geo_data_sca' function
  data_uprn_sca_lookup <- merge_geo_data_sca(geo_data = data_geo_uprn,
                                             sca_path_eng = sca_path_eng,
                                             sca_path_wal = sca_path_wal,
                                             long_var = long_var,
                                             lat_var = lat_var)
  
  # Return merged dataset
  return(data_uprn_sca_lookup)
  
}