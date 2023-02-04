library(dplyr)
library(lubridate)
library(tidyr)
library(fable)
library(tsibble)
library(tsibbledata)

create_projection_set <- function(dt_project_from,
                                  max_horizon = 3,
                                  dt_earliest_to_use = as.Date("2016-01-01"),
                                  gp_ratios,
                                  births_actual,
                                  gp_0) {

  ts_ratios <- get_ts_ratios(gp_ratios,
                             dt_min = dt_earliest_to_use,
                             dt_max = dt_project_from)

  ts_model <- ts_ratios %>%
    model(ETS =  ETS(ratio ~ error("A") +
                       trend() + season("N")))

  model_forecast <- forecast(ts_model, h = max_horizon)

  projected_ratios <- model_forecast %>%
    hilo(95) %>%
    mutate(ratio_lower = `95%`$lower,
           ratio_upper = `95%`$upper) %>%
    mutate(year = floor(date_index),
           month = 1 + (date_index - year) * 12) %>%
    mutate(date = as.Date(paste0(year, "-", month, "-", "01"))) %>%
    data.frame() %>%
    select(gss_code, gss_name,
           geography, sex,
           date,
           model = .model,
           ratio = .mean,
           ratio_lower,
           ratio_upper)

  #project births
  gp_based_prediction <- projected_ratios %>%
    inner_join(gp_0, by = c("gss_code", "gss_name", "geography", "sex", "date")) %>%
    mutate(predicted_births = round(ratio * gp_count, 1),
           interval_lower = round(ratio_lower * gp_count, 1),
           interval_upper = round(ratio_upper * gp_count, 1)) %>%
    select(-c(ratio, ratio_lower, ratio_upper, gp_count)) %>%
    arrange(gss_code, sex, date)

  #naive predicted births
  naive_prediction <- births_actual %>%
    filter(date == dt_project_from) %>%
    select(-date) %>%
    rename(naive = annual_births)

  #combine predicted and actuals
  birth_comparison <- gp_based_prediction %>%
    inner_join(births_actual, by = c("gss_code", "gss_name", "geography", "sex", "date")) %>%
    rename(actual_births = annual_births) %>%
    left_join(naive_prediction, by = c("gss_code", "gss_name", "geography", "sex")) %>%
    mutate(horizon = (date - dt_project_from)) %>%
    mutate(horizon = round(as.numeric(horizon)/30.4, 0)) %>%
    filter(sex == "persons") %>%
    mutate(projection_date = dt_project_from)

  return(birth_comparison)
}
