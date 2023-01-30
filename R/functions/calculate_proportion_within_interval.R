library(dplyr)

calculate_proportion_within_interval <- function(birth_comparisons,
                                                 gss_exclude = c("E09000001", "E06000053")) {

  prop_within_interval <- birth_comparisons %>%
    bind_rows() %>%
    filter(!gss_code %in% gss_exclude) %>%
    mutate(within_interval = case_when(
      (actual_births >= interval_lower & actual_births <= interval_upper) ~ TRUE,
      TRUE ~ FALSE)) %>%
    group_by(geography, model) %>%
    summarise(prop_within_interval = round(sum(within_interval)/n(), 3),
              number_areas = n(),
              .groups = "drop") %>%
    arrange(number_areas)

  return(prop_within_interval)
}
