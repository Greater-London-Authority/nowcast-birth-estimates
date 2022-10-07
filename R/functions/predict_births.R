predict_births <- function(birth_gp_coeff, gp_0) {

  coeffs <- birth_gp_coeff %>%
    select(gss_code, gss_name, mean_ratio, sd_ratio)

  births_predicted <- gp_0 %>%
    left_join(coeffs, by = c("gss_code", "gss_name")) %>%
    mutate(ci_lower = round((mean_ratio - 2 * sd_ratio) * gp_count, 1),
           ci_upper = round((mean_ratio + 2 * sd_ratio) * gp_count, 1),
           births = round(mean_ratio * gp_count), 1) %>%
    select(gss_code, gss_name, date, births, ci_lower, ci_upper)

  return(births_predicted)
}
