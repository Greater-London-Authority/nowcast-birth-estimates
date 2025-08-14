library(dplyr)
source("R/functions/aggregate_to_region.R")

fpath <- list(lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_lad_itl = "lookups/lookup_lad_itl.rds",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds",
              births_lad = "data/raw/births_lad.rds",
              dir_processed = "data/processed/",
              dir_intermediate = "data/intermediate/",
              births_actual = "data/processed/births_actual.rds")

if(!file.exists(fpath$births_lad)) stop("Input birth data file not found")

if(!dir.exists(fpath$dir_processed)) dir.create(fpath$dir_processed)
if(!dir.exists(fpath$dir_intermediate)) dir.create(fpath$dir_intermediate)


#read input births for local authorities; aggregate to higher geographies; combine into single file

births_lad <- readRDS(fpath$births_lad) %>%
  filter(grepl("E0", gss_code)) %>%
  mutate(geography = "LAD23") %>%
  mutate(sort_order = 3) %>%
  select(gss_code, gss_name, geography, measure, date = year_ending_date, sex, value, sort_order)

births_rgn <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_rgn),
                                  "RGN23") %>%
  na.omit() %>%
  mutate(sort_order = 2)

births_itl <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_itl),
                                  "ITL221") %>%
  mutate(sort_order = 4)

births_ctry <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_ctry),
                                  "CTRY23") %>%
  mutate(sort_order = 1)

births_actual <- bind_rows(births_lad,
                           births_rgn,
                           births_itl,
                           births_ctry) %>%
  arrange(sort_order, gss_code, date) %>%
  select(-sort_order)

saveRDS(births_actual, fpath$births_actual)
