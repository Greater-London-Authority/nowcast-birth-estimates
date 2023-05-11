library(dplyr)
library(readr)

#if the gglaplot package is not installed, use alternative plotting functions
is_gglaplot_installed <- require(gglaplot)
if(is_gglaplot_installed){
  source("R/functions/plot_predicted_births.R")
  source("R/functions/plot_predicted_births_indexed.R")
} else {
  source("R/functions/alt_plot_predicted_births.R")
  source("R/functions/alt_plot_predicted_births_indexed.R")
}

fpath <- list(births_actual = "data/processed/births_actual.rds",
              actual_and_predicted_births_rds = "outputs/actual_and_predicted_births.rds",
              dir_plots = "outputs/plots/",
              lookup_gss = "outputs/plots/gss_code_to_name_lookup.csv"
              )

if(!dir.exists(fpath$dir_plots)) dir.create(fpath$dir_plots)

#read and consolidate birth data read for plotting

births_modelled <- readRDS(fpath$actual_and_predicted_births_rds)

births_actual <- readRDS(fpath$births_actual) %>%
  filter(date < min(births_modelled$date)) %>%
  rename(annual_births = value) %>%
  select(-measure) %>%
  mutate(type = "actual")

births_all <- bind_rows(births_actual,
                        births_modelled) %>%
  mutate(type2 = recode(type,
                       "interpolated" = "past",
                       "actual" = "past"))

rm(births_actual, births_modelled)

#create and save a lookup to help users
births_all %>%
  select(name = gss_name, code = gss_code, geography) %>%
  distinct() %>%
  write_csv(fpath$lookup_gss)

last_date <- max(births_all$date)

#-------------create plots-------------------


all_cds <- unique(births_all$gss_code) #generate plots for every area in the data by default

#plot last five years of births
fstub <- "_5yrs.png"

fig_height <- 3
fig_width <- 5

for(sel_cd in all_cds) {

  dir_plt <- paste0(fpath$dir_plots, sel_cd, "/")
  if(!dir.exists(dir_plt)) dir.create(dir_plt)

  plot_predicted_births(sel_cd,
                            births_all,
                            dt_plot_start = last_date - years(5),
                            d_breaks = "3 months",
                            pt_size = 2,
                            b_size = 6)

  ggsave(filename = paste0(dir_plt, sel_cd, fstub),
         device = "png", height = fig_height, width = fig_width)
}

#plot last fifteen years of births
fstub <- "_15yrs.png"

fig_height <- 3
fig_width <- 5

for(sel_cd in all_cds) {

  dir_plt <- paste0(fpath$dir_plots, sel_cd, "/")
  if(!dir.exists(dir_plt)) dir.create(dir_plt)

  plot_predicted_births(sel_cd,
                        births_all,
                        dt_plot_start = last_date - years(15),
                        d_breaks = "1 year",
                        pt_size = 2,
                        b_size = 6)

  ggsave(filename = paste0(dir_plt, sel_cd, fstub),
         device = "png", height = fig_height, width = fig_width)
}

#plot last thirty years of births
fstub <- "_25yrs.png"

fig_height <- 3
fig_width <- 5

for(sel_cd in all_cds) {

  dir_plt <- paste0(fpath$dir_plots, sel_cd, "/")
  if(!dir.exists(dir_plt)) dir.create(dir_plt)

  plot_predicted_births(sel_cd,
                        births_all,
                        dt_plot_start = last_date - years(25),
                        d_breaks = "2 years",
                        pt_size = 2,
                        b_size = 6)

  ggsave(filename = paste0(dir_plt, sel_cd, fstub),
         device = "png", height = fig_height, width = fig_width)
}

#plot births since 2001, indexed to 2012
# fstub <- "_births_from_2001_indexed_to_2012.png"
#
# for(sel_cd in all_cds) {
#
#   dir_plt <- paste0(fpath$dir_plots, sel_cd, "/")
#   if(!dir.exists(dir_plt)) dir.create(dir_plt)
#
#   plot_predicted_births_indexed(sel_cd,
#                                 births_all,
#                                 dt_plot_start = as.Date("2001-01-01"),
#                                 dt_relative_to = as.Date("2012-07-01"),
#                                 d_breaks = "2 years",
#                                 pt_size = 2)
#
#   ggsave(filename = paste0(dir_plt, sel_cd, fstub),
#          device = "png", height = fig_height, width = fig_width)
# }
