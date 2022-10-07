library(tidyverse)

fpath <- list(raw_mye_coc = "data/raw/mye_2020_components_EW_(2021_geog).rds",
              births_my_lad = "data/intermediate/births_my_lad.rds")

readRDS(fpath$raw_mye_coc) %>%
  filter(component == "births",
         age == 0) %>%
  mutate(date = as.Date(paste0(year, "-07-01"), "%Y-%m-%d")) %>%
  group_by(gss_code, gss_name, date) %>%
  summarise(value = sum(value), .groups = "drop") %>%
  saveRDS(fpath$births_my_lad)
