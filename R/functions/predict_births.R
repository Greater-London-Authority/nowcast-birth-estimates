predict_births <- function(birth_gp_coeff, gp_0) {

  coeffs <- birth_gp_coeff %>%
    select(any_of(c("gss_code", "gss_name", "geography", "sex", "mean_ratio", "sd_ratio")))

  births_predicted <- gp_0 %>%
    left_join(coeffs, by = NULL) %>%
    mutate(annual_births = round(mean_ratio * gp_count, 1),
           ci_lower = round((mean_ratio - 2 * sd_ratio) * gp_count, 1),
           ci_upper = round((mean_ratio + 2 * sd_ratio) * gp_count, 1)) %>%
    select(-c(gp_count, mean_ratio, sd_ratio))

  return(births_predicted)
}
