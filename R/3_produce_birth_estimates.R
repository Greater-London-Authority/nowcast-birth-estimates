library(dplyr)
library(readr)

source("R/functions/project_ratios_ets.R")
source("R/functions/interpolate_gp_ratios.R")

fpath <- list(births_actual = "data/processed/births_actual.rds",
              gp_0 = "data/processed/gp_age_0.rds",
              actual_and_predicted_births_rds = "outputs/actual_and_predicted_births.rds",
              actual_and_predicted_births_csv = "outputs/actual_and_predicted_births.csv",
              gp_ratios_rds = "outputs/birth_gp_ratios.rds",
              gp_ratios_csv = "outputs/birth_gp_ratios.csv")

#--- calculate past ratios of births to gp counts ----
births_actual <- readRDS(fpath$births_actual) %>%
  rename(annual_births = value) %>%
  select(-measure)

gp_0 <- readRDS(fpath$gp_0) %>%
  rename(gp_count = value) %>%
  select(-measure)

gp_ratios <- inner_join(births_actual, gp_0,
                        by = c("gss_code", "gss_name", "geography", "date", "sex")) %>%
  mutate(ratio = annual_births/gp_count) %>%
  select(-c(annual_births, gp_count)) %>%
  arrange(gss_code, sex, date)

dates_actual_births <- unique(births_actual$date)
dates_actual_ratios <- unique(gp_ratios$date)

#-----------project future ratios -----------
#currently using exponential smoothing method from the Fable package

projected_ratios <- project_ratios_ets(gp_ratios,
                                       max_horizon = 6,
                                       dt_min = as.Date("2015-01-01"),
                                       dt_max = as.Date("2050-01-01"))

#---------Interpolate ratios ----------------
#past and future ratios are for mid and calendar years
#interpolate ratios for each month

monthly_ratios <- bind_rows(
  interpolate_gp_ratios(gp_ratios, w_intervals = FALSE),
  interpolate_gp_ratios(projected_ratios, w_intervals = TRUE)
) %>%
  mutate(ratio_type = case_when(
    date > max(dates_actual_ratios) ~ "predicted",
    date %in% dates_actual_ratios ~ "actual",
    TRUE ~ "interpolated"
  ))


ratio_output <- monthly_ratios %>%
  arrange(gss_code, sex, date) %>%
  left_join(gp_0, by = c("gss_code", "gss_name", "geography", "sex", "date")) %>%
  left_join(births_actual, by = c("gss_code", "gss_name", "geography", "sex", "date")) %>%
  rename(actual_births = annual_births)

#--------Generate births from ratios ---------
#multiply projected/interpolated ratios by monthly gp counts to get births

actual_and_predicted_births <- monthly_ratios %>%
  select(-ratio_type) %>%
  inner_join(gp_0, by = c("gss_code", "gss_name", "geography", "sex", "date")) %>%
  mutate(birth_type = case_when(
    date > max(dates_actual_births) ~ "predicted",
    date %in% dates_actual_births ~ "actual",
    TRUE ~ "interpolated"
  )) %>%
  mutate(annual_births = round(ratio * gp_count, 1),
         interval_lower = round(ratio_lower * gp_count, 1),
         interval_upper = round(ratio_upper * gp_count, 1)) %>%
  select(-c(ratio, ratio_lower, ratio_upper, gp_count)) %>%
  arrange(gss_code, sex, date)

#write births and ratios to output folder as RDS and CSV
saveRDS(actual_and_predicted_births, fpath$actual_and_predicted_births_rds)
write_csv(actual_and_predicted_births, fpath$actual_and_predicted_births_csv, na = "")

saveRDS(ratio_output, fpath$gp_ratios_rds)
write_csv(ratio_output, fpath$gp_ratios_csv, na = "")
