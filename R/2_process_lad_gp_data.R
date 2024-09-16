library(dplyr)
library(readr)
source("R/functions/aggregate_to_region.R")

fpath <- list(gp_sya = "data/raw/gp_sya_lad.rds",
              gp_0 = "data/processed/gp_age_0.rds",
              lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_lad_itl = "lookups/lookup_lad_itl.rds",
              dir_processed = "data/processed/",
              dir_intermediate = "data/intermediate/",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds")

if(!file.exists(fpath$gp_sya)) stop("Input GP count data file not found")

if(!dir.exists(fpath$dir_processed)) dir.create(fpath$dir_processed)
if(!dir.exists(fpath$dir_intermediate)) dir.create(fpath$dir_intermediate)

#read input gp data for local authorities; aggregate to higher geographies; combine into single file

gp_0_lad <- readRDS(fpath$gp_sya) %>%
  filter(sex == "persons",
         age == 0,
         grepl("E0", gss_code)) %>%
  mutate(measure = "gp_count_age_0") %>%
  select(gss_code, gss_name, geography, measure, date = extract_date, sex, value) %>%
  mutate(sort_order = 3)

gp_0_rgn <- aggregate_to_region(gp_0_lad,
                                readRDS(fpath$lookup_lad_rgn),
                                "RGN23") %>%
  mutate(sort_order = 2)

gp_0_itl <- aggregate_to_region(gp_0_lad,
                                readRDS(fpath$lookup_lad_itl),
                                "ITL221") %>%
  mutate(sort_order = 4)

gp_0_ctry <- aggregate_to_region(gp_0_lad,
                                 readRDS(fpath$lookup_lad_ctry),
                                 "CTRY23") %>%
  mutate(sort_order = 1)

gp_0 <- bind_rows(gp_0_lad,
                  gp_0_rgn,
                  gp_0_itl,
                  gp_0_ctry) %>%
  arrange(sort_order, gss_code, date, sex) %>%
  select(-sort_order)

saveRDS(gp_0, fpath$gp_0)
