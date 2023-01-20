library(dplyr)
library(readr)

source("R/functions/project_ratios.R")
source("R/functions/interpolate_past_gp_ratios.R")
source("R/functions/interpolate_projected_gp_ratios.R")

fpath <- list(births_actual = "data/processed/births_actual.rds",
              gp_0 = "data/processed/gp_age_0.rds",
              actual_and_predicted_births_rds = "outputs/actual_and_predicted_births.rds",
              actual_and_predicted_births_csv = "outputs/actual_and_predicted_births.csv")

births_actual <- readRDS(fpath$births_actual) %>%
  rename(annual_births = value) %>%
  select(-measure)

dts_actual_births <- unique(births_actual$date)

gp_0 <- readRDS(fpath$gp_0) %>%
  rename(gp_count = value) %>%
  select(-measure)

gp_ratios <- inner_join(births_actual, gp_0,
                        by = c("gss_code", "gss_name", "geography", "date", "sex")) %>%
  mutate(ratio = annual_births/gp_count) %>%
  select(-c(annual_births, gp_count)) %>%
  arrange(gss_code, sex, date)

dt_last_actual_ratio <- max(gp_ratios$date)

dates_int_projected <- gp_0 %>%
  filter(date > dt_last_actual_ratio) %>%
  select(date) %>%
  distinct() %>%
  pull(date)

dates_int_past <- gp_0 %>%
  filter(date < dt_last_actual_ratio) %>%
  select(date) %>%
  distinct() %>%
  pull(date)

#-----------project future ratios -----------
#currently using exponential smoothing method from the Fable package

projected_ratios <- project_ratios_ets(gp_ratios)

#---------Interpolate ratios ----------------
#past and future ratios are for mid and calendar years
#interpolate ratios for each month

interpolated_ratios <- bind_rows(
  interpolate_past_gp_ratios(gp_ratios, dates_int_past),
  interpolate_projected_gp_ratios(projected_ratios, dates_int_projected)
)

#--------Generate births from ratios ---------
#multiply projected/interpolated ratios by monthly gp counts to get births

actual_and_predicted_births <- interpolated_ratios %>%
  left_join(gp_0, by = c("gss_code", "gss_name", "geography", "sex", "date")) %>%
  mutate(annual_births = ratio * gp_count,
         interval_upper = ratio_upper * gp_count,
         interval_lower = ratio_lower * gp_count) %>%
  mutate(type = case_when(
    date > dt_last_actual_ratio ~ "predicted",
    date %in% dts_actual_births ~ "actual",
    TRUE ~ "interpolated"
  )) %>%
  select(-c(ratio, ratio_lower, ratio_upper, gp_count)) %>%
  arrange(gss_code, sex, date)

#write to output folder as RDS and CSV
saveRDS(actual_and_predicted_births, fpath$actual_and_predicted_births_rds)
write_csv(actual_and_predicted_births, fpath$actual_and_predicted_births_csv, na = "")
