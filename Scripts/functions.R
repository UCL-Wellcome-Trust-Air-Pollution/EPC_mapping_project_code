# Name of script: functions
# Description:  SOurces all necessary functions to build analysis pipeline
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 03-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 03-09-2024
# Update notes: 

# Comments ---------------------------------------------------------------------

# Main directory for all necessary functions to run main EPC analysis pipeline

# Source functions -------------------------------------------------------------

source(here("Scripts/CleanDataEPC.R"))
source(here("Scripts/MergeGeoDataSCA.R"))
source(here("Scripts/MergeDataEPCCleanedCovars.R"))
source(here("Scripts/MakeChoroplethMap.R"))
source(here("Scripts/MakeGroupedScatterPlot.R"))
source(here("Scripts/MakeSummaryDataByGroup.R"))
source(here("Scripts/UtilityFunctions.R"))
source(here("Scripts/MakeLSOALookupData.R"))
source(here("Scripts/PrepareDataToMap.R"))
source(here("Scripts/MakeDataEPCCoverage.R"))
source(here("Scripts/MakeUPRNSCALookup.R"))
source(here("Scripts/MakePatchworkPlot.R"))
source(here("Scripts/MakeLAEIData.R"))
source(here("Scripts/GetOpenairData.R"))
source(here("Scripts/MergeOpenairEPCData.R"))
source(here("Scripts/MakeScatterPlotOpenair.R"))
source(here("Scripts/SetSpatialPoints.R"))
source(here("Scripts/MakeOpenairEPCLAEIData.R"))
source(here("Scripts/MakePatchworkPlotOpenair.R"))