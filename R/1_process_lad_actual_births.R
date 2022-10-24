library(tidyverse)
source("R/functions/aggregate_to_region.R")

fpath <- list(lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_lad_itl = "lookups/lookup_lad_itl.rds",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds",
              births_lad = "data/raw/births_lad.rds",
              births_actual = "data/processed/births_actual.rds")

births_lad <- readRDS(fpath$births_lad) %>%
  select(gss_code, gss_name, date = year_ending_date, sex, value)

births_rgn <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_rgn)) %>%
  na.omit()

births_itl <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_itl))

births_ctry <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_ctry))

births_actual <- bind_rows(births_lad,
                           births_rgn,
                           births_itl,
                           births_ctry) %>%
  rename(births = value) %>%
  arrange(gss_code, date)

saveRDS(births_actual, fpath$births_actual)
