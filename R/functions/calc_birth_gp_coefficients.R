calc_birth_gp_coefficients <- function(births_actual, gp_0, date_start, date_end){

  births_gp0 <- inner_join(births_actual, gp_0,
                           by = NULL)

  if(!is.na(as.Date(date_start))) {
    date_start <- as.Date(date_start)
    } else {
      date_start <- min(births_gp0$date)
    }

  if(!is.na(as.Date(date_end))) {
    date_end <- as.Date(date_end)
  } else {
    date_end <- max(births_gp0$date)
  }

  mean_ratios <- births_gp0 %>%
    filter(between(date, date_start, date_end)) %>%
    group_by(across(-any_of(c("annual_births", "gp_count", "date")))) %>%
    summarise(annual_births = sum(annual_births),
              gp_count = sum(gp_count),
              .groups = "drop") %>%
    mutate(mean_ratio = annual_births/gp_count) %>%
    select(-c(annual_births, gp_count))

  sd_ratios <- births_gp0 %>%
    filter(between(date, date_start, date_end)) %>%
    mutate(ratio = annual_births/gp_count) %>%
    na.omit() %>%
    group_by(across(-any_of(c("annual_births", "gp_count", "ratio", "date")))) %>%
    summarise(sd_ratio = sd(ratio),
              .groups = "drop")

  birth_gp_correlation <- births_gp0 %>%
    filter(between(date, date_start, date_end)) %>%
    group_by(across(-any_of(c("annual_births", "gp_count", "date")))) %>%
    summarise(correlation_coefficient = cor(x = gp_count, y = annual_births), .groups = "drop")

  out_df <- mean_ratios %>%
    left_join(sd_ratios, by = NULL) %>%
    left_join(birth_gp_correlation, by = NULL) %>%
    mutate(period_start = date_start,
           period_end = date_end)

  return(out_df)
}
