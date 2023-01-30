library(dplyr)
source("R/functions/plot_predicted_births_pts.R")
source("R/functions/plot_predicted_births_indexed.R")

fpath <- list(births_actual = "data/processed/births_actual.rds",
              actual_and_predicted_births_rds = "outputs/actual_and_predicted_births.rds",
              dir_plots = "outputs/plots/"
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
  mutate(type2 = type,
         type = recode(type,
                       "interpolated" = "actual")) %>%
  mutate(interval_upper = case_when(
    type == "actual" ~ annual_births,
    TRUE ~ interval_upper
  )) %>%
  mutate(interval_lower = case_when(
    type == "actual" ~ annual_births,
    TRUE ~ interval_lower
  )) %>%
  arrange(gss_code, sex, date)

rm(births_actual, births_modelled)

#-------------create plots-------------------

all_cds <- unique(births_all$gss_code) #generate plots for every area in the data by default

#plot births since 2011
fstub <- "_births_from_2011.png"

for(sel_cd in all_cds) {

  dir_plt <- paste0(fpath$dir_plots, sel_cd, "/")
  if(!dir.exists(dir_plt)) dir.create(dir_plt)

  plot_predicted_births_pts(sel_cd,
                            filter(births_all, type2 != "interpolated"),
                            dt_actual_start = as.Date("2011-01-01"),
                            d_breaks = "6 months",
                            exc_actual_line = FALSE,
                            pt_size = 3)

  ggsave(filename = paste0(dir_plt, sel_cd, fstub),
         device = "png", height = 6, width = 12)
}

# births since 2016 including interpolated figures
fstub <- "_births_from_2016_w_interpolation.png"

for(sel_cd in all_cds) {

  dir_plt <- paste0(fpath$dir_plots, sel_cd, "/")
  if(!dir.exists(dir_plt)) dir.create(dir_plt)

  plot_predicted_births_pts(sel_cd,
                            births_all,
                            dt_actual_start = as.Date("2016-01-01"),
                            d_breaks = "3 months",
                            exc_actual_line = FALSE,
                            pt_size = 1)

  ggsave(filename = paste0(dir_plt, sel_cd, fstub),
         device = "png", height = 6, width = 12)
}


#plot births since 1993, indexed to 2012
fstub <- "_births_from_1993_indexed_to_2012.png"

for(sel_cd in all_cds) {

  dir_plt <- paste0(fpath$dir_plots, sel_cd, "/")
  if(!dir.exists(dir_plt)) dir.create(dir_plt)

  plot_predicted_births_indexed(sel_cd,
                                filter(births_all, type2 != "interpolated"),
                                dt_actual_start = as.Date("1993-01-01"),
                                dt_relative_to = as.Date("2012-07-01"),
                                d_breaks = "2 years",
                                exc_actual_line = FALSE)

  ggsave(filename = paste0(dir_plt, sel_cd, fstub),
         device = "png", height = 6, width = 12)
}

#plot births since 1993
fstub <- "_births_from_1993.png"

for(sel_cd in all_cds) {

  dir_plt <- paste0(fpath$dir_plots, sel_cd, "/")
  if(!dir.exists(dir_plt)) dir.create(dir_plt)

  plot_predicted_births_pts(sel_cd,
                            filter(births_all, type2 != "interpolated"),
                            dt_actual_start = as.Date("1993-01-01"),
                            d_breaks = "2 years",
                            exc_actual_line = FALSE,
                            pt_size = 1)

  ggsave(filename = paste0(dir_plt, sel_cd, fstub),
         device = "png", height = 6, width = 12)
}
