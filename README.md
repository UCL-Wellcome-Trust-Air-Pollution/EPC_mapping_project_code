# EPC mapping project code base
This repository stores the code files for the project - "High resolution mapping of wood burning hotspots using Energy Performance Certificates: A case study in England and Wales". To recreate the analysis on your local device, please carry out the following steps:

1. Clone the GitHub repository to your local device. For users who do not have Git installed on their local machine, a zip file of the code base is available via Zenodo ('Code.zip'). Please ensure you use the directory with the R Project in it (which is called "EPC_mapping_project_code.RProj") as your root directory.

2. Download the 'Data.tar' file from (https://zenodo.org/records/14888530) and unzip the file in the R Project directory. The data should be in a folder called 'Data' in the root directory. All data is provided under the UK Open Government License version 3.0

3. Download the main EPC data to your local device and unzip (see below for detailed instructions on how to do this). For Windows users, the 'Scripts' folder of the repository contains a .bat file which can be used to unzip the data. Note that this file requires the user to have installed 7Zip and added 7Zip to the system path. Otherwise, the .tar file can be unzipped manually.

4. In an R terminal, run 'renv::restore()'. This should install all the necessary packages to replicate the analysis. On Linux/MacOS operating systems, there may be errors relating to re-installing specific packages from the renv lockfile. If this happens, install the package manually from source (install.packages("package_name", type = "source"), then run 'renv::snapshot()' and choose option 2 (build snapshot from installed packages), then run 'renv::restore()' again. Some packages (e.g. "sf") also require additional dependencies to be installed on Linux. Please install these dependencies before running 'renv::restore()'. An issue has been reported relating to the "qs" package not being found in the library paths. If this error occurs, one fix would be to comment out the line of code `format = "qs"' in line 46 of the _targets.R file. Note that this may slow down the pipeline.
   
5. Once the project library has been successfully loaded, run the 'run.R' file in the 'Scripts' folder of the directory. You may need to change the 'path_data_epc_folders' variable to the path to the unzipped EPC data folders on your local device (see step 3). The full pipeline should now run.

6. Once you have run the pipeline for the first time, you should see a file called 'data_epc_raw.parquet' in the 'Data/raw/epc_data' folder. If you run the pipeline again, you will be prompted that the raw EPC data .parquet file already exists, and you have the option to skip the merging of raw data files.

## Downloading the main EPC data

EPC data is provided under license for research purposes by the Department of Levelling Up, Housing, and Communities: https://epc.opendatacommunities.org/docs/copyright. To access the data, you need to sign up at the following link: https://epc.opendatacommunities.org/login. Once you have signed up/logged in to the EPC site, navigate to the 'Domestic EPC' tab and click the 'Download all results (.zip)' icon in the top right of the screen. This will download a large .zip file of EPC certificates by Local Authority. Unzip this folder in your R Project directory and take note of the path to the parent folder. You need to set this path as the 'path_data_epc_folders' variable in step 4 above.
