library(tidyverse)

fpath <- list(raw_births_cy_lsoa = "data/raw/births_cy_lsoa.csv",
              births_cy_lad = "data/intermediate/births_cy_lad.rds",
              lookup_lsoa_lad = "data/intermediate/lookup_lsoa_lad.rds")

births_cy <- read_csv(fpath$raw_births_cy_lsoa,
                          skip = 5) %>%
  rename(LSOA11NM = 1,
         LSOA11CD = 2) %>%
  pivot_longer(cols = -c(1:2),
               names_to = "year",
               values_to = "value") %>%
  select(-LSOA11NM) %>%
  mutate(year = as.numeric(year)) %>%
  left_join(readRDS(fpath$lookup_lsoa_lad), by = c("LSOA11CD")) %>%
  na.omit() %>%
  mutate(date = as.Date(paste0(year + 1, "-01-01"), "%Y-%m-%d")) %>%
  group_by(gss_code, gss_name, date) %>%
  summarise(value = sum(value), .groups = "drop")

saveRDS(births_cy, fpath$births_cy_lad)
