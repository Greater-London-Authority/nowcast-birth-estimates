library(dplyr)

calculate_forecast_errors <- function(birth_comparison) {

  model_names <- c(unique(birth_comparison$model), "naive")

  forecast_errors <- birth_comparison %>%
    select(-c(interval_upper, interval_lower)) %>%
    pivot_wider(names_from = "model", values_from = "predicted_births") %>%
    pivot_longer(cols = any_of(model_names),
                 names_to = "model",
                 values_to = "predicted_births") %>%
    mutate(err = predicted_births - actual_births,
           abs_err = abs(err),
           perc_err = 100 * err/actual_births,
           abs_perc_err = abs(perc_err))

  return(forecast_errors)
}
