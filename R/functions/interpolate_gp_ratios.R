library(dplyr)
library(tidyr)
library(zoo)

interpolate_gp_ratios <- function(in_ratios, dt_min,
                                  w_intervals = FALSE){

  sel_dates <- seq.Date(from = dt_min,
                        to = max(in_ratios$date),
                        by = "1 month")

  if(w_intervals){
    out_ratios <- in_ratios %>%
      filter(date <= max(sel_dates)) %>%
      complete(nesting(gss_code, gss_name, geography, sex), date = sel_dates) %>%
      arrange(date) %>%
      group_by(gss_code, gss_name, geography, sex) %>%
      mutate(ratio = na.approx(ratio, rule = 2),
             ratio_lower = na.approx(ratio_lower, rule = 2),
             ratio_upper = na.approx(ratio_upper, rule = 2)) %>%
    data.frame()
  }
  else{
    out_ratios <- in_ratios %>%
      filter(date <= max(sel_dates)) %>%
      complete(nesting(gss_code, gss_name, geography, sex), date = sel_dates) %>%
      arrange(date) %>%
      group_by(gss_code, gss_name, geography, sex) %>%
      mutate(ratio = na.approx(ratio, rule = 2)) %>%
    data.frame()
  }
  return(out_ratios)
}
