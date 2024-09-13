# Name of script: WriteDataToFile
# Description:  Defines function to write dataset to specified file path
# and geographical resolution
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 12-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 12-09-2024
# Update notes: 

# Define function to write data to file ----------------------------------------

write_data_to_file <- function(data, path, file_type){
  
  file_path <- paste0(path, "/", deparse(substitute(data)), file_type)
  
  # Write data to file
  write.csv(data, file_path)
  
  return(file_path)
  
}