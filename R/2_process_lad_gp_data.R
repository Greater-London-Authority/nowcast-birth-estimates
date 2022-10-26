library(tidyverse)
library(readr)
source("R/functions/aggregate_to_region.R")

fpath <- list(gp_sya = "data/raw/gp_sya_lad.rds",
              gp_0 = "data/processed/gp_age_0.rds",
              gp_0_output = "outputs/gp_count_age_0.csv",
              gp_0_output_wide = "outputs/gp_count_age_0_wide.csv",
              lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_lad_itl = "lookups/lookup_lad_itl.rds",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds")

gp_0_lad <- readRDS(fpath$gp_sya) %>%
  filter(sex == "persons",
         age == 0,
         grepl("E0", gss_code)) %>%
  mutate(measure = "gp_count_age_0") %>%
  select(gss_code, gss_name, geography, measure, date = extract_date, sex, value) %>%
  mutate(sort_order = 3)

gp_0_rgn <- aggregate_to_region(gp_0_lad,
                                readRDS(fpath$lookup_lad_rgn),
                                "RGN21") %>%
  mutate(sort_order = 2)

gp_0_itl <- aggregate_to_region(gp_0_lad,
                                readRDS(fpath$lookup_lad_itl),
                                "ITL221") %>%
  mutate(sort_order = 4)

gp_0_ctry <- aggregate_to_region(gp_0_lad,
                                 readRDS(fpath$lookup_lad_ctry),
                                 "CTRY21") %>%
  mutate(sort_order = 1)

gp_0 <- bind_rows(gp_0_lad,
                  gp_0_rgn,
                  gp_0_itl,
                  gp_0_ctry) %>%
  arrange(sort_order, gss_code, date, sex) %>%
  select(-sort_order)

saveRDS(gp_0, fpath$gp_0)

write_csv(gp_0, fpath$gp_0_output)

gp_0_wide <- gp_0 %>%
  pivot_wider(names_from = "date", values_from = "value")

write_csv(gp_0_wide, fpath$gp_0_output_wide)
