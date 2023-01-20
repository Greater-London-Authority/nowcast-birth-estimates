library(dplyr)
library(tidyr)
library(zoo)

interpolate_projected_gp_ratios <- function(projected_ratios, sel_dates){

  interpolated_ratios <- projected_ratios %>%
    filter(date <= max(sel_dates)) %>%
    complete(nesting(gss_code, gss_name, geography, sex), date = sel_dates) %>%
    arrange(date) %>%
    group_by(gss_code, gss_name, geography, sex) %>%
    mutate(ratio = na.approx(ratio, rule = 2),
           ratio_lower = na.approx(ratio_lower, rule = 2),
           ratio_upper = na.approx(ratio_upper, rule = 2))
    data.frame()

  return(interpolated_ratios)
}
