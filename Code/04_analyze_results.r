### analyze results

# packages ---------------------------------------------------------------------
library(bibliometrix)
library(readxl)
library(stargazer)
library(tidyverse)

# parameters -------------------------------------------------------------------
dir_rfiles <- "Data/r_files"
dir_output <- "Data/output"
dir_input <- "Data/input"

# load data --------------------------------------------------------------------
data_wos_base <- read_rds(file.path(dir_rfiles, "data_wos_base.rds"))
data_wos_jour <- read_rds(file.path(dir_rfiles, "data_wos_jour.rds"))
data_results_full <- read_rds(file.path(dir_rfiles, "data_results_full.rds"))
data_results <- read_rds(file.path(dir_rfiles, "data_results.rds"))

data_included <- read_xlsx(file.path(dir_input, "in_evaluation.xlsx")) %>%
  filter(included_read == 1) %>%
  select(paper, id)

# reference corpus -------------------------------------------------------------

## publications ----------------------------------------------------------------
data_wos_base %>%
  mutate(SO = fct_lump_min(SO, 10)) %>%
  count(SO) %>%
  as.data.frame() %>%
  stargazer(type = "html", summary = FALSE, out = file.path(dir_output, "pub_jour_ref.html"))

## publication period ----------------------------------------------------------
data_wos_base %>%
  mutate(PY = case_when(PY <= 1990 ~ 1, PY <= 2000 ~ 2, PY <= 2010 ~ 3, PY <= 2021 ~ 4)) %>%
  mutate(PY = as_factor(PY)) %>%
  mutate(PY = fct_recode(PY, "1985-1990" = "1", "1991-2000" = "2", "2001-2010" = "3", "2011-2021" = "4")) %>%
  count(PY)

## wos keywords ----------------------------------------------------------------
data_wos_base %>%
  mutate(ID = str_split(ID, ";")) %>%
  unnest(cols = ID) %>%
  mutate(ID = str_squish(ID)) %>%
  count(ID, sort = TRUE)

# base corpus ------------------------------------------------------------------

## publications ----------------------------------------------------------------
data_wos_jour %>%
  filter(PY >= 1998 | is.na(PY)) %>%
  count(SO) %>%
  as.data.frame() %>%
  stargazer(type = "html", summary = FALSE, out = file.path(dir_output, "pub_jour_base.html"))

## publication period ----------------------------------------------------------
data_wos_jour %>%
  filter(PY >= 1998 | is.na(PY)) %>%
  mutate(PY = case_when(PY <= 2004 ~ 1, PY <= 2009 ~ 2, PY <= 2014 ~ 3, PY <= 2021 ~ 4)) %>%
  mutate(PY = as_factor(PY)) %>%
  mutate(PY = fct_recode(PY, "1998-2004" = "1", "2005-2009" = "2", "2010-2014" = "3", "2015-2021" = "4")) %>%
  count(PY)

# results ----------------------------------------------------------------------

## publications ----------------------------------------------------------------
data_wos_jour %>%
  filter(id %in% data_included$id) %>%
  group_by(SO) %>%
  summarise(n = n(), citations = sum(TC)) %>%
  mutate(average_citations = citations / n) %>%
  as.data.frame() %>%
  stargazer(type = "html", summary = FALSE, out = file.path(dir_output, "pub_jour_result.html"))

## publication period ----------------------------------------------------------
data_wos_jour %>%
  filter(id %in% data_included$id) %>%
  mutate(PY = case_when(PY <= 2004 ~ 1, PY <= 2009 ~ 2, PY <= 2014 ~ 3, PY <= 2021 ~ 4)) %>%
  mutate(PY = as_factor(PY)) %>%
  mutate(PY = fct_recode(PY, "1998-2004" = "1", "2005-2009" = "2", "2010-2014" = "3", "2015-2021" = "4")) %>%
  count(PY) %>%
  as.data.frame() %>%
  stargazer(type = "html", summary = FALSE, out = file.path(dir_output, "pub_period_result.html"))

## wos keywords ----------------------------------------------------------------
data_wos_jour %>%
  filter(id %in% data_included$id) %>%
  mutate(ID = str_split(ID, ";")) %>%
  unnest(cols = ID) %>%
  mutate(ID = str_squish(ID)) %>%
  count(ID, sort = TRUE)
