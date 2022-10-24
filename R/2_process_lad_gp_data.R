library(tidyverse)
source("R/functions/aggregate_to_region.R")

fpath <- list(gp_sya = "data/raw/gp_sya_lad.rds",
              gp_0 = "data/processed/gp_age_0.rds",
              lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_lad_itl = "lookups/lookup_lad_itl.rds",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds")

gp_0_lad <- readRDS(fpath$gp_sya) %>%
  filter(sex == "persons",
         age == 0,
         grepl("E0", gss_code)) %>%
  select(gss_code, gss_name, date = extract_date, value)

gp_0_rgn <- aggregate_to_region(gp_0_lad,
                                readRDS(fpath$lookup_lad_rgn))

gp_0_itl <- aggregate_to_region(gp_0_lad,
                                readRDS(fpath$lookup_lad_itl))

gp_0_ctry <- aggregate_to_region(gp_0_lad,
                                 readRDS(fpath$lookup_lad_ctry))

gp_0 <- bind_rows(gp_0_lad,
                  gp_0_rgn,
                  gp_0_itl,
                  gp_0_ctry) %>%
  arrange(gss_code, date)

saveRDS(gp_0, fpath$gp_0)
