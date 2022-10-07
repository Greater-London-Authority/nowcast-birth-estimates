source("R/functions/aggregate_to_region.R")

fpath <- list(births_cy_lad = "data/intermediate/births_cy_lad.rds",
              births_my_lad = "data/intermediate/births_my_lad.rds",
              lookup_lad_rgn = "data/intermediate/lookup_lad_rgn.rds",
              lookup_lad_itl = "data/intermediate/lookup_lad_itl.rds",
              lookup_lad_ctry = "data/intermediate/lookup_lad_ctry.rds",
              births_actual = "data/processed/births_actual.rds")

births_lad <- bind_rows(readRDS(fpath$births_cy_lad),
                        readRDS(fpath$births_my_lad))

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
  arrange(gss_code, date)

saveRDS(births_actual, fpath$births_actual)
