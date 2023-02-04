library(dplyr)
library(lubridate)
library(tidyr)
library(fable)
library(tsibble)
library(tsibbledata)

project_ratios_ets <- function(gp_ratios,
                               max_horizon = 6,
                               dt_min = as.Date("2015-01-01"),
                               dt_max = as.Date("2050-01-01")) {

  ts_ratios <- gp_ratios %>%
    filter(between(date, dt_min, dt_max)) %>%
    mutate(date_index = year(date) + (month(date) - 1)/12) %>%
    select(-date) %>%
    as_tsibble(index = date_index,
               key = c(gss_code, gss_name, geography, sex))

  ts_model <- ts_ratios %>%
    model(ets = ETS(ratio ~ error("A") +
                    trend() + season("N"))) %>%
    forecast(h = max_horizon)

  projected_ratios <- ts_model %>%
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
           ratio = .mean,
           ratio_lower,
           ratio_upper)

  return(projected_ratios)
}
