

get_epc_data <- function(path_data_epc_folders,
                                  epc_cols_to_select = c("UPRN", "SECONDHEAT_DESCRIPTION", "MAINHEAT_DESCRIPTION",
                                                         "INSPECTION_DATE", "CONSTRUCTION_AGE_BAND", "PROPERTY_TYPE",
                                                         "BUILT_FORM", "TENURE", "POSTCODE"),
                         output_dir = "Data/raw/epc_data"){
  
  # Create function to prompt for yes/no input
  prompt_user <- function() {
    
    while (TRUE) {
      # Prompt the user for input
      response <- tolower(readline(prompt = "The file 'data_epc_raw.parquet' already exists in this location. Do you want to re-run the merging process? [y/n]"))
      
      # If response is y, run merging script
      if (response == "y") {
        
        message("Running merging script.")
        
        return(TRUE)
        
      # If response is n, skip merging script  
      } else if (response == "n") {
        
        message("Skipping merging script.")
        
        return(FALSE)
      
      # If response is invalid, prompt again  
      } else {
        
        message("Invalid input. Please enter 'y' or 'n'.")
        
      }
    }
  }
  
  # If output directory does not exist, create it
  dir.create(file.path(here(output_dir)), showWarnings = FALSE)
  
  # Check if output data already exists - if yes, prompt whether want to rerun the script
  if(file_exists(paste0(output_dir, "/data_epc_raw.parquet"))) {
    
    response <- prompt_user()
  
  # If response is 'yes' then re-run the merging script
  if(response == TRUE){
    
    # Check if input directory exists
    if(dir.exists(path_data_epc_folders)){
      
      print("Starting merge")
  
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
      
      print("Finished merge")
      
      # Save data frame as parquet to specified path
      write_parquet(data_epc_raw, paste0(output_dir, "/data_epc_raw.parquet"))
    
    # If directory to raw EPC data does not exist, return an error and skip merging script
    } else {
      
      print("The specified directory for the unzipped EPC data does not exist. Please check that the directory is correctly specified, and that the data exists.")
      
    }
  
  }
    
  } else {
    
    # Check if input directory exists
    if(dir.exists(path_data_epc_folders)){
      
      print("Starting merge")
      
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
      
      print("Finished merge")
      
      # Save data frame as parquet to specified path
      write_parquet(data_epc_raw, paste0(output_dir, "/data_epc_raw.parquet"))
      
      # If directory to raw EPC data does not exist, return an error and skip merging script
    } else {
      
      print("The specified directory for the unzipped EPC data does not exist. Please check that the directory is correctly specified, and that the data exists.")
      
    }
    
  }
  
}