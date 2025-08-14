library(dplyr)
library(readr)

source("R/functions/project_ratios_ets.R")
source("R/functions/interpolate_gp_ratios.R")

fpath <- list(births_actual = "data/processed/births_actual.rds",
              gp_0 = "data/processed/gp_age_0.rds",
              dir_outputs = "outputs/",
              actual_and_predicted_births_rds = "outputs/actual_and_predicted_births.rds",
              actual_and_predicted_births_csv = "outputs/actual_and_predicted_births.csv",
              gp_ratios_rds = "outputs/birth_gp_ratios.rds",
              gp_ratios_csv = "outputs/birth_gp_ratios.csv")

if(!dir.exists(fpath$dir_outputs)) dir.create(fpath$dir_outputs)

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
                                       max_horizon = 5,
                                       dt_min = as.Date("2016-07-01"),
                                       dt_max = as.Date("2050-01-01"))

#---------Interpolate ratios ----------------
#past and future ratios are for mid and calendar years
#interpolate ratios for each month
#TODO fix unrealistic interpolated prediction intervals for months up to h = 1

#for the months before h = 1, interpolate mean ratio between the projected and last actual
#assign these prediction intervals that are the same width as those at h = 1

dt_h1 <- min(projected_ratios$date)

initial_interval_widths <- projected_ratios %>%
  filter(date == dt_h1) %>%
  mutate(width_lower = ratio - ratio_lower,
         width_upper = ratio_upper - ratio) %>%
  select(gss_code, sex, width_lower, width_upper)

monthly_projected_ratios <- interpolate_gp_ratios(projected_ratios,
                             min(projected_ratios$date),
                             w_intervals = TRUE)



monthly_ratios <- interpolate_gp_ratios(bind_rows(gp_ratios, monthly_projected_ratios),
                                        min(dates_actual_ratios),
                                        w_intervals = FALSE) %>%
  mutate(ratio_type = case_when(
    date > max(dates_actual_ratios) ~ "predicted",
    date %in% dates_actual_ratios ~ "actual",
    TRUE ~ "interpolated"
  )) %>%
  left_join(initial_interval_widths, by = c("gss_code", "sex")) %>%
  mutate(ratio_lower = case_when(
    (date < dt_h1 & ratio_type == "predicted") ~ ratio - width_lower,
    TRUE ~ ratio_lower
  )) %>%
  mutate(ratio_upper = case_when(
    (date < dt_h1 & ratio_type == "predicted") ~ ratio + width_upper,
    TRUE ~ ratio_upper
  )) %>%
  select(-c(width_lower, width_upper))



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
  mutate(type = case_when(
    date > max(dates_actual_births) ~ "predicted",
    date %in% dates_actual_births ~ "actual",
    TRUE ~ "interpolated"
  )) %>%
  mutate(annual_births = round(ratio * gp_count, 1),
         interval_lower = round(ratio_lower * gp_count, 1),
         interval_upper = round(ratio_upper * gp_count, 1)) %>%
  select(-c(ratio, ratio_lower, ratio_upper, gp_count))

earlier_actual_births <- births_actual %>%
  filter(date < min(actual_and_predicted_births$date)) %>%
  mutate(type = "actual",
         interval_lower = as.numeric(NA),
         interval_upper = as.numeric(NA)) %>%
  select(colnames(actual_and_predicted_births))

full_actual_and_predicted_births <- bind_rows(
  earlier_actual_births,
  actual_and_predicted_births) %>%
  arrange(gss_code, sex, date)


#write births and ratios to output folder as RDS and CSV
saveRDS(full_actual_and_predicted_births, fpath$actual_and_predicted_births_rds)
write_csv(full_actual_and_predicted_births, fpath$actual_and_predicted_births_csv, na = "")

saveRDS(ratio_output, fpath$gp_ratios_rds)
write_csv(ratio_output, fpath$gp_ratios_csv, na = "")
