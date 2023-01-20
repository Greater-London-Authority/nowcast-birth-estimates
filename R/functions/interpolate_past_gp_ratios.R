library(dplyr)
library(tidyr)
library(zoo)

interpolate_past_gp_ratios <- function(gp_ratios, sel_dates){

  interpolated_ratios <- gp_ratios %>%
    complete(nesting(gss_code, gss_name, geography, sex), date = sel_dates) %>%
    arrange(date) %>%
    group_by(gss_code, gss_name, geography, sex) %>%
    mutate(ratio = na.approx(ratio, rule = 2)) %>%
    data.frame()

  return(interpolated_ratios)
}
