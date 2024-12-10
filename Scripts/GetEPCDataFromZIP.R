

get_epc_data_from_zip <- function(path_data_epc_folders,
                                  epc_cols_to_select = c("UPRN", "SECONDHEAT_DESCRIPTION", "MAINHEAT_DESCRIPTION",
                                                         "INSPECTION_DATE", "CONSTRUCTION_AGE_BAND", "PROPERTY_TYPE",
                                                         "BUILT_FORM", "TENURE", "POSTCODE")){
  
  # We put the 'path_data_epc_zipped' as an argument so the script reruns when the .zip file changes
  
  # Set up multiprocess
  plan(multisession, workers = 2)

  # Get all subdirectories inside the EPC folder directory
  subfolders <- dir_ls(path_data_epc_folders, type = "directory")
  
  # Read and bind all 'certificates.csv' files into a single dataframe
  data_epc_raw <- subfolders %>%
    
    future_map_dfr(~ {
      
      # Define the path to the certificates.csv file
      csv_path <- file.path(.x, "certificates.csv")
      
      # Check if the file exists
      if (file_exists(csv_path)) {
        
        # Read the CSV file using vroom
        vroom(csv_path, col_select = epc_cols_to_select)
        
      } else {
        
        # If the file doesn't exist, return an empty dataframe
        tibble()
        
      }
    })
  
  # Set plan back to sequential
  plan(sequential)
  
  # Return merged dataframe
  return(data_epc_raw)
  
}