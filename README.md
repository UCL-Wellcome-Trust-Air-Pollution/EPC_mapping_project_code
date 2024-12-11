# EPC_mapping_project_code
This repository stores the code files for the project - "High resolution mapping of wood burning hotspots using Energy Performance Certificates: A case study in England and Wales". To recreate the analysis on your local device, please carry out the following steps:

1. Clone the GitHub repository to your local device

2. Download the 'Data.tar' file from https://zenodo.org/records/14382720 and unzip the file in the R Project directory. The data should be in a folder called 'Data'. All data is provided under the UK Open Government License version 3.0

3. Download the main EPC data to your local device and unzip (see below for detailed instructions on how to do this)

4. Run the 'run.R' file in the 'Scripts' folder of the directory. YOu may need to change the 'path_data_epc_folders' variable to the path to the unzipped EPC data folders on your local device

## Downloading the main EPC data

EPC data is provided under license for research purposes by the Department of Levelling Up, Housing, and Communities. To access the data, you need to sign up at the following link: https://epc.opendatacommunities.org/login. Once you have signed up/logged in to the EPC site, click the 'Download all results (.zip)' icon in the top right of the screen. THis will download a large .zip file of EPC certificates by Local Authority. Unzip this folder in your R Project directory. 
