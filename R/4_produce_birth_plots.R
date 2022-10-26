library(dplyr)
source("R/functions/plot_predicted_births.R")

fpath <- list(births_all = "data/processed/births_all.rds")

births_all <- readRDS(fpath$births_all)

all_cds <- unique(births_all$gss_code)

for(sel_cd in all_cds) {

  plt_from_2016 <- plot_predicted_births_pts(sel_cd, births_all,
                                             dt_actual_start = as.Date("2016-01-01"),
                                             dt_pred_start = as.Date("2020-01-01"),
                                             d_breaks = "3 months",
                                             exc_actual_line = FALSE)

  ggsave(filename = paste0("outputs/plots/from_2016/", sel_cd, ".png"),
         plot = plt_from_2016,
         device = "png",
         height = 6, width = 12)
}

for(sel_cd in all_cds) {

  plt_index_2012 <- plot_predicted_births_indexed(sel_cd, births_all,
                                                  dt_actual_start = as.Date("2012-06-30"),
                                                  dt_pred_start = as.Date("2021-01-01"),
                                                  dt_relative_to = as.Date("2012-07-01"),
                                                  d_breaks = "6 months",
                                                  exc_actual_line = TRUE)

  ggsave(filename = paste0("outputs/plots/indexed_from_2012/", sel_cd, ".png"),
         plot = plt_index_2012,
         device = "png",
         height = 6, width = 12)
}

for(sel_cd in all_cds) {

plt_from_1992 <- plot_predicted_births_line(sel_cd, births_all,
                                            dt_actual_start = as.Date("1992-01-01"),
                                            dt_pred_start = as.Date("2022-01-01"),
                                            d_breaks = "2 years")

ggsave(filename = paste0("outputs/plots/from_1992/", sel_cd, ".png"),
       plot = plt_from_1992,
       device = "png",
       height = 6, width = 12)
}
