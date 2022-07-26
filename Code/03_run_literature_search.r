### run literature search

# packages ---------------------------------------------------------------------
library(readxl)
library(stargazer)
library(tidytext)
library(tidyverse)
library(writexl)

# setup ------------------------------------------------------------------------
dir_rfiles <- "Data/r_files"
dir_output <- "Data/output"
dir_input <- "Data/input"
data_wos_jour <- read_rds(file.path(dir_rfiles, "data_wos_jour.rds"))

# run text search --------------------------------------------------------------

## define search patterns ------------------------------------------------------
pat_int <- c(
  "abroad",
  "border(?!line)",
  "export",
  "foreign(?!e|i|n)",
  "geographic",
  "global",
  "internation",
  "mn[ce]s?$",
  "multination",
  "offshore",
  "transnation",
  "subsidiar[iy]"
)
pat_flx <- c(
  "allocat",
  "deploy",
  "flexib",
  "^options?",
  "(?<!mobile)platform",
  "relocat",
  "switch",
  "(?<!sublimation)shift"
)
pat_opr <- c(
  "^capacity",
  "facilit[iy]",
  "(?<!col|e)labou?r(?!at|ing)",
  "logistics",
  "manufactur",
  "(?<!inter)network",
  "(?<!co|peri)operat(?!ionaliz|ionalis|tor)",
  "(?<!im|sup|trans)plant(?!ation|ing)",
  "(?<!co|re)production",
  "(?<!crowd)sourcing",
  "suppl[iy]"
)
pat_rsk <- c(
  "crisis",
  "(?<!con|crypto)currenc[iy]",
  "exchange$",
  "expos(?!i)",
  "fluctuation",
  "(?<!aste)risk",
  "uncertain",
  "volatil",
  "^variance"
)

len_max <- max(map_int(list(pat_int, pat_flx, pat_opr, pat_rsk), length))
pattern_srch <- tibble(
  pat_int = c(pat_int, rep(NA, len_max - length(pat_int))),
  pat_flx = c(pat_flx, rep(NA, len_max - length(pat_flx))),
  pat_opr = c(pat_opr, rep(NA, len_max - length(pat_opr))),
  pat_rsk = c(pat_rsk, rep(NA, len_max - length(pat_rsk)))
)

## run search ------------------------------------------------------------------
data_srch <- data_wos_jour %>%
  filter(is.na(PY) | PY >= 1998) %>%
  select(id, TI, DE, ID, AB) %>%
  gather(value = text, key = type, -id) %>%
  mutate(text = str_replace_all(text, "[:digit:]", " ")) %>%
  mutate(text = str_replace_all(text, "[:punct:]", " ")) %>%
  mutate(text = str_squish(text)) %>%
  select(-type) %>%
  unnest_tokens(word, text) %>%
  unique() %>%
  anti_join(stop_words, by = "word") %>%
  filter(str_length(word) > 2)

results_int <- tibble(type = "int", pattern = pat_int) %>%
  mutate(hit = map(pattern, ~ filter(data_srch, str_detect(word, .x)))) %>%
  unnest(cols = c(hit)) %>%
  unique()

results_flx <- tibble(type = "flx", pattern = pat_flx) %>%
  mutate(hit = map(pattern, ~ filter(data_srch, str_detect(word, .x)))) %>%
  unnest(cols = c(hit)) %>%
  unique()

results_opr <- tibble(type = "opr", pattern = pat_opr) %>%
  mutate(hit = map(pattern, ~ filter(data_srch, str_detect(word, .x)))) %>%
  unnest(cols = c(hit)) %>%
  unique()

results_rsk <- tibble(type = "rsk", pattern = pat_rsk) %>%
  mutate(hit = map(pattern, ~ filter(data_srch, str_detect(word, .x)))) %>%
  unnest(cols = c(hit)) %>%
  unique()

# check results by pattern -----------------------------------------------------
data_results_full <- bind_rows(
  results_int,
  results_flx,
  results_opr,
  results_rsk
)

## print hits ------------------------------------------------------------------
map(unique(data_results_full$type), ~ {
  data_results_full %>%
    filter(type == .x) %>%
    count(pattern)
})

## print hit pattern -----------------------------------------------------------
hit_pattern <- data_results_full %>%
  select(id, type) %>%
  unique() %>%
  mutate(n = TRUE) %>%
  spread(key = type, value = n) %>%
  select(-id) %>%
  mice::md.pattern() %>%
  as_tibble(rownames = "hits") %>%
  mutate(hits = as.numeric(hits))
hit_pattern$hits[[16]] <- sum(hit_pattern$hits, na.rm = TRUE)  
stargazer(
  as.data.frame(hit_pattern),
  summary = FALSE, 
  type = "html",
  out = "Data/out_xlsx/hit_pattern.html"
  )

## hit-word --------------------------------------------------------------------
data_results_full %>%
  filter(type == "int") %>%
  ggplot() +
  geom_bar(aes(word), show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~ pattern, scales = "free") +
  labs(
    title = "Multinationality",
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(
    title = element_text(size = 16),
    axis.text = element_text(size = 12)
  )
ggsave("Plots/pattern_int.png", width = 16, height = 16, dpi = 600)

data_results_full %>%
  filter(type == "flx") %>%
  ggplot() +
  geom_bar(aes(word), show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~ pattern, scales = "free") +
  labs(
    title = "Flexibility",
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(
    title = element_text(size = 16),
    axis.text = element_text(size = 12)
  )
ggsave("Plots/pattern_flx.png", width = 12, height = 16, dpi = 600)

data_results_full %>%
  filter(type == "opr") %>%
  ggplot() +
  geom_bar(aes(word), show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~ pattern, scales = "free") +
  labs(
    title = "Operations",
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(
    title = element_text(size = 16),
    axis.text = element_text(size = 12)
  )
ggsave("Plots/pattern_opr.png", width = 16, height = 16, dpi = 600)

data_results_full %>%
  filter(type == "rsk") %>%
  ggplot() +
  geom_bar(aes(word), show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~ pattern, scales = "free") +
  labs(
    title = "Uncertainty",
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(
    title = element_text(size = 16),
    axis.text = element_text(size = 12)
  )
ggsave("Plots/pattern_unc.png", width = 12, height = 16, dpi = 600)

## hit-pattern -----------------------------------------------------------------
facet_names <- c("Flexibility", "Multinationality", "Operations", "Uncertainty")
names(facet_names) <- c("flx", "int", "opr", "rsk")

data_results_full %>%
  mutate(type = as_factor(str_replace_all(type, facet_names))) %>%
  mutate(type = fct_relevel(type, c("Multinationality", "Flexibility", "Operations", "Uncertainty"))) %>%
  select(-word) %>%
  unique() %>%
  ggplot() +
  geom_bar(aes(pattern), show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~ type, scales = "free") +
  labs(
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(
    axis.text = element_text(size = 12)
  )
ggsave("Plots/pattern_summary.png", width = 14, height = 14, dpi = 600)

# define search terms ----------------------------------------------------------
data_results <- data_results_full %>%
  select(-word) %>%
  mutate(pattern = TRUE) %>%
  unique() %>%
  spread(key = type, value = pattern) %>%
  group_by(id, flx, int, opr, rsk) %>%
  summarise(cnt = sum(flx, int, opr, rsk, na.rm = TRUE)) %>%
  ungroup() %>%
  right_join(data_wos_jour, by = "id") %>%
  select(id, AU, TI, AB, cnt) %>%
  select(id, cnt) %>%
  left_join(data_wos_jour, by = "id") %>%
  unique()

# create to do list ------------------------------------------------------------
if (file.exists(file.path(dir_input, "in_evaluation.xlsx"))) {
  tmp <- data_results %>%
    filter(cnt == 4) %>%
    select(-cnt)
  papers_todo <- anti_join(tmp, read_xlsx(file.path(dir_input, "in_evaluation.xlsx")), by = "id")
} else {
  papers_todo <- data_results %>%
    filter(cnt == 4) %>%
    select(-cnt)
}
print(papers_todo)

# save results -----------------------------------------------------------------
saveRDS(data_results_full, file = file.path(dir_rfiles, "data_results_full.rds"))
saveRDS(data_results, file = file.path(dir_rfiles, "data_results.rds"))

write_xlsx(unique(select(papers_todo, id, AU, PY, TI, SO, VL, NR, BP, EP)), path = file.path(dir_output, "papers_todo.xlsx"))
write_xlsx(unique(select(data_results, id, AU, PY, TI, SO, VL, NR, BP, EP)), path = file.path(dir_output, "data_results.xlsx"))
