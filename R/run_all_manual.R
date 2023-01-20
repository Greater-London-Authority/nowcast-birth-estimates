#process input data - only necessary to rerun when new input data added
source("R/1_process_lad_actual_births.R")
source("R/2_process_lad_gp_data.R")

#produce modelled births
source("R/3_produce_birth_estimates.R")

#optional - produce plots of births for each area
#notes:
#     this can take ~15 mins to run
#     current implementation requires that the gglaplot package be installed
source("R/4_produce_birth_plots.R")
