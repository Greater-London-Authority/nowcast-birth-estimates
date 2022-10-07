calc_birth_gp_coefficients <- function(births_actual, gp_0, date_start, date_end){

  births_gp0 <- inner_join(births_actual, gp_0,
                           by = c("gss_code", "gss_name", "date"))

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
    group_by(gss_code, gss_name) %>%
    summarise(births = sum(births),
              gp_count = sum(gp_count),
              .groups = "drop") %>%
    mutate(mean_ratio = births/gp_count) %>%
    select(-c(births, gp_count))

  sd_ratios <- births_gp0 %>%
    filter(between(date, date_start, date_end)) %>%
    mutate(ratio = births/gp_count) %>%
    na.omit() %>%
    group_by(gss_code, gss_name) %>%
    summarise(sd_ratio = sd(ratio),
              .groups = "drop")

  birth_gp_correlation <- births_gp0 %>%
    filter(between(date, date_start, date_end)) %>%
    group_by(gss_code, gss_name) %>%
    summarise(corr_coef = cor(x = gp_count, y = births), .groups = "drop")

  out_df <- mean_ratios %>%
    left_join(sd_ratios, by = c("gss_code", "gss_name")) %>%
    left_join(birth_gp_correlation, by = c("gss_code", "gss_name")) %>%
    mutate(period_start = date_start,
           period_end = date_end)

  return(out_df)
}
