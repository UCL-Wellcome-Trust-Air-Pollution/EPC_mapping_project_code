# Name of script: run.R
# Description: Master script to run pipeline in '_targets.R' script
# Created by: Calum Kennedy (calum.kennedy.20@ucl.ac.uk)
# Created on: 20-09-2024
# Latest update by: Calum Kennedy
# Latest update on: 27-09-2024

# Run pipeline -----------------------------------------------------------------

# Uncomment to run sequentially without parallelisation
targets::tar_make()

# Uncomment to run targets in parallel on your local machine (specify number of workers)

#targets::tar_make_future(workers = 2)

# Uncomment to run targets in parallel
# on local processes or a Sun Grid Engine cluster.
# targets::tar_make_clustermq(workers = 2L)