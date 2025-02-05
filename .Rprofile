source("renv/activate.R")

# Always prefer tidylog
conflicted::conflict_prefer_all("tidylog", c("dplyr", "gtsummary", "stats", "papeR", "ggpubr"))

# Prefer dplyr to data.table
conflicted::conflict_prefer_all("dplyr", "data.table")

# Prefer lubridate year
conflicted::conflicts_prefer(lubridate::year)
