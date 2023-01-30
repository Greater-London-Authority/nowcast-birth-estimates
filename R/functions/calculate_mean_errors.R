library(dplyr)

calculate_mean_errors <- function(forecast_errors,
                                  grp_vars = c("model", "horizon", "geography", "projection_date"),
                                  gss_exclude = c("E09000001", "E06000053")) {

  mean_errors <- forecast_errors %>%
    filter(!gss_code %in% gss_exclude) %>%
    group_by(across(all_of(grp_vars))) %>%
    summarise(MAE = round(mean(abs_err), 1),
              MAPE = round(mean(abs_perc_err), 2),
              number_areas = n(), .groups = "drop")

  return(mean_errors)
}
