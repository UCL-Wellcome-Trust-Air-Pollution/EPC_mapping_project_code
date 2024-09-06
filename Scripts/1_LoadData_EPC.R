# Name of script: 1_LoadData.R
# Description:  Loads Energy Performance Certificate data 
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 23-08-2024
# Latest update by: Calum Kennedy
# Latest update on: 03-09-2024
# Update notes: Updated code to modularise into separate scripts

# Comments ---------------------------------------------------------------------

# Note - I use the {here} package to set relative file paths for the whole project
# This allows any user with a copy of the R project to access files in their local
# repository without having to update the file path, since the path is defined 
# in relative terms. See here for more: https://here.r-lib.org/. 

# Set directory path and source scripts ----------------------------------------

source(paste0(root_path, "Scripts/0_LoadEnv.R")) 
source(paste0(root_path, "Scripts/api_keys.R"))

# Set globals ------------------------------------------------------------------

# List of relevant columns to select
epc_cols_to_select <- c("uprn", "secondheat-description", "mainheat-description",
                        "inspection-date", "construction-age-band", "property-type",
                        "built-form", "tenure", "postcode")

# Define strings for missing data to set to NA
na_strings <- c("na", "n a", "n / a", "n/a", "n/ a", "not available", "invalid!",
                "no data!", "not applicable", ",", "")

# Set up functions and values to use in loop -----------------------------------

# Define base url to access EPC data
base_url <- "https://epc.opendatacommunities.org/api/v1/domestic/search"

# Define query parameters for filtering results
query_params <- list(size = "5000")

# Set up authentication
headers <- list(
  Accept = 'application/json',
  Authorization = paste0('Basic ', api_key)
)

# Set initial value of 'search_after'
search_after = ""

# Function to append data frames to the database
append_to_db <- function(df, table_name, conn) {
  
  dbWriteTable(conn, table_name, df, append = TRUE, row.names = FALSE)
  
}

# Extract data to file ---------------------------------------------------------

# Establish a connection
con <- dbConnect(duckdb(), dbdir = here("Data/raw/epc_data/data_epc.duckdb"))

# Remove table if already present
if(dbExistsTable(con, "data_epc")){dbRemoveTable(con, "data_epc")}

# Initialize an empty list to store data frames
batch_list <- list()

# Set batch size
batch_size <- 5

# Counter for the current batch size
current_batch <- 0

# While there are additional pages of results, continue to run the loop below
while(!is.null(search_after)){
  
  # Set next 'search_after' value to query
  query_params$`search-after` <- search_after
  
  # Set parameters for current query and get response
  response <- request(base_url) %>%
    
    # Set custom headers and query parameters
    req_headers(!!!headers) %>%
    
    req_url_query(!!!query_params) %>%
    
    # Perform the request
    req_perform()
  
  # Extract response body
  body <- response %>%
    
    # Extract text from response object
    resp_body_json()
  
  # Create data frame from body object and select relevant columns
  dat <- rbindlist(body$rows) %>%
    
    select(all_of(epc_cols_to_select))
  
  # Add the new data frame to the batch list
  batch_list[[length(batch_list) + 1]] <- dat
  
  # Increment the batch counter
  current_batch <- current_batch + 1
  
  # If the batch size is reached, write to the database and reset the batch
  if (current_batch >= batch_size) {
    
    combined_df <- rbindlist(batch_list) %>%
    
      # Mutate values to lower case where variable type is character
      mutate_if(is.character,  ~ tolower(.)) %>%
      
      # Replace all strings in 'na_strings' with NA
      mutate(across(everything(), ~ case_when(. %in% na_strings ~ NA_character_,
                             .default = .))) %>%

      # Mutate variable for year of EPC
      mutate(year = year(ymd(`inspection-date`)))

    append_to_db(combined_df, "data_epc", con)
      
    print("iter")
    
    # Reset batch list and counter
    batch_list <- list()
    
    current_batch <- 0
  }
  
  # Now extract next 'search_after' value
  search_after <- resp_headers(response)$`X-Next-Search-After`
  
}

# Write any remaining data frames in the batch to the database
if (length(batch_list) > 0) {
  
  combined_df <- rbindlist(batch_list)
  
  append_to_db(combined_df, "data_epc", con)
}

# Disconnect from DB
dbDisconnect(con)
