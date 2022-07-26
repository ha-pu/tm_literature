### import and prepare data

# packages =====================================================================
library(bibliometrix)
library(tidyverse)

# setup ------------------------------------------------------------------------
dir_input <- "Data/input"
dir_wos_base <- file.path(dir_input, "wos_base")
dir_wos_jour <- file.path(dir_input, "wos_jour")
dir_rfiles <- "Data/r_files"

# import data ------------------------------------------------------------------
data_wos_base <- tibble(folder = dir_wos_base) %>%
  mutate(folder = map(folder, list.dirs)) %>%
  unnest(cols = c(folder)) %>%
  slice(-1) %>%
  mutate(file = map(folder, list.files)) %>%
  unnest(cols = c(file)) %>%
  mutate(bib_df = map2(folder, file, ~ as_tibble(convert2df(file = file.path(.x, .y), dbsource = "wos", format = "plaintext")))) %>%
  select(bib_df) %>%
  unnest(cols = c(bib_df)) %>%
  rename(id = UT) %>%
  mutate_if(is.character, str_to_lower) %>%
  unique()

data_wos_jour <- tibble(folder = dir_wos_jour) %>%
  mutate(folder = map(folder, list.dirs)) %>%
  unnest(cols = c(folder)) %>%
  slice(-1) %>%
  mutate(file = map(folder, list.files)) %>%
  unnest(cols = c(file)) %>%
  mutate(bib_df = map2(folder, file, ~ as_tibble(convert2df(file = file.path(.x, .y), dbsource = "wos", format = "plaintext")))) %>%
  select(bib_df) %>%
  unnest(cols = c(bib_df)) %>%
  unique() %>%
  rename(id = UT) %>%
  mutate_if(is.character, str_to_lower)

# save data --------------------------------------------------------------------
saveRDS(data_wos_base, file = file.path(dir_rfiles, "data_wos_base.rds"))
saveRDS(data_wos_jour, file = file.path(dir_rfiles, "data_wos_jour.rds"))
