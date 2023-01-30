library(dplyr)
library(lubridate)
library(tidyr)
library(fable)
library(tsibble)
library(tsibbledata)

get_ts_ratios <- function(gp_ratios,
                          dt_min,
                          dt_max){

  ts_ratios <- gp_ratios %>%
    filter(between(date, dt_min, dt_max)) %>%
    mutate(date_index = year(date) + (month(date) - 1)/12) %>%
    select(-date) %>%
    as_tsibble(index = date_index,
               key = c(gss_code, gss_name, geography, sex))

  return(ts_ratios)
}
