library(dplyr)
library(readr)
library(lubridate)

source("R/functions/calc_birth_gp_coefficients.R")
source("R/functions/predict_births.R")

fpath <- list(births_actual = "data/processed/births_actual.rds",
              gp_0 = "data/processed/gp_age_0.rds",
              predicted_births_output = "outputs/predicted_births.csv",
              actual_births_output = "outputs/actual_births.csv",
              gp_age_0_output = "outputs/gp_age_0_count.csv",
              birth_gp_coeff = "outputs/model_coefficients.csv",
              births_all = "outputs/births_all.rds",
              actual_and_predicted_births = "outputs/actual_and_predicted_births.csv")

# these dates define the period on which the model bases the relationships between patient counts and
# annual births used to predict recent births
date_start <- "2018-07-01"
# leave as "" to use up to the date of the most recent actual birth data
date_end <- ""

#-----

births_actual <- readRDS(fpath$births_actual) %>%
  rename(annual_births = value) %>%
  select(-measure)

gp_0 <- readRDS(fpath$gp_0) %>%
  rename(gp_count = value) %>%
  select(-measure) %>%
  filter(date >= as.Date(date_start))

birth_gp_coeff <- calc_birth_gp_coefficients(births_actual, gp_0, date_start, date_end)

births_predicted <- predict_births(birth_gp_coeff, gp_0) %>%
  filter(date >= as.Date(date_start))

births_all <- bind_rows(
  births_actual %>%
    mutate(ci_lower = annual_births, ci_upper = annual_births, type = "actual"),
  births_predicted %>%
    mutate(type = "predicted")
) %>%
  rename(year_ending_date = date)

actual_and_predicted_births <- births_actual %>%
  rename(actual_births = annual_births) %>%
  full_join(rename(births_predicted, predicted_births = annual_births), by = NULL) %>%
  full_join(gp_0, by = NULL) %>%
  rename(year_ending_date = date) %>%
  arrange(geography, gss_code, sex, year_ending_date)

actual_births_output <- births_actual %>%
  rename(year_ending_date = date) %>%
  mutate(type = "actual")

predicted_births_output <- births_predicted %>%
  rename(year_ending_date = date) %>%
  mutate(type = "predicted")

gp_age_0_output <- readRDS(fpath$gp_0) %>%
  filter(date >= as.Date(date_start))

saveRDS(births_all, fpath$births_all)
write_csv(birth_gp_coeff, fpath$birth_gp_coeff)
write_csv(predicted_births_output, fpath$predicted_births_output)
write_csv(actual_births_output, fpath$actual_births_output)
write_csv(actual_and_predicted_births, fpath$actual_and_predicted_births, na = "")
write_csv(gp_age_0_output, fpath$gp_age_0_output)
