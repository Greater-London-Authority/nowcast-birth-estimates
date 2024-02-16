#process input data - only necessary to rerun when new input data added
source("R/1_process_lad_actual_births.R")
source("R/2_process_lad_gp_data.R")

#produce modelled births
source("R/3_produce_birth_estimates.R")

#optional - produce plots of births for each area
#     this can take ~15 mins to run
#     plots will be created using gglaplot if package installed, standard ggplot2 if not
source("R/4_produce_birth_plots.R")

# optional - produces a draft html page for checking by a human and zips up plots folder
source("R/5_prepare_datastore_update.R")

# To do the datastore upload run R/6_update_datastore.R
# The file is not sourced here to avoid accidental updates.
