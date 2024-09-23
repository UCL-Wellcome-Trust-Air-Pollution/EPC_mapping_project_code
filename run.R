# Name of script: run.R
# Description: Master script to run pipeline in '_targets.R' script
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 03-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 20-09-2024
# Update notes: Changed function to refer to arbitrary grouping variables

# Run pipeline -----------------------------------------------------------------

# Uncomment to run targets sequentially on your local machine.
targets::tar_make()

# Uncomment to run targets in parallel
# on local processes or a Sun Grid Engine cluster.
# targets::tar_make_clustermq(workers = 2L)