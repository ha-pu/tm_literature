### extract term frequency

# packages =====================================================================
library(readxl)
library(tidytext)
library(tidyverse)
library(wordcloud)
library(writexl)

# setup ------------------------------------------------------------------------
dir_rfiles <- "Data/r_files"
dir_output <- "Data/out_xlsx"
dir_input <- "Data/in_raw"

# run document comparison ======================================================

## document-word comparison ----------------------------------------------------
data_wos_base <- read_rds(file.path(dir_rfiles, "data_wos_base.rds"))
data_wos_jour <- read_rds(file.path(dir_rfiles, "data_wos_jour.rds"))
data_wos_jour <- filter(data_wos_jour, !(id %in% data_wos_base$id) & PY >= 1998)

# get term frequency for terms in base
data_base <- data_wos_base %>%
  select(id, TI, DE, ID, AB) %>%
  gather(value = text, key = type, -id) %>%
  mutate(text = str_replace_all(text, "[:digit:]", " ")) %>%
  mutate(text = str_replace_all(text, "[:punct:]", " ")) %>%
  mutate(text = str_squish(text)) %>%
  select(-type) %>%
  unnest_tokens(word, text) %>%
  filter(str_length(word) > 1) %>%
  group_by(id) %>%
  count(word) %>%
  mutate(tot = sum(n)) %>%
  mutate(tf = n / tot) %>%
  ungroup()

# get inverse document frequency for terms in jour
data_jour <- data_wos_jour %>%
  select(id, TI, DE, ID, AB) %>%
  gather(value = text, key = type, -id) %>%
  mutate(text = str_replace_all(text, "[:digit:]", " ")) %>%
  mutate(text = str_replace_all(text, "[:punct:]", " ")) %>%
  mutate(text = str_squish(text)) %>%
  select(-type) %>%
  unnest_tokens(word, text) %>%
  filter(str_length(word) > 1) %>%
  unique() %>%
  count(word) %>%
  rename(len_c_t = n) %>%
  mutate(len_c = length(unique(data_wos_jour$id))) %>%
  mutate(
    len_c_t = len_c_t + 1,
    len_c = len_c + 1
  ) %>%
  mutate(idf = log(len_c / len_c_t))

data_docwrd <- data_base %>%
  left_join(data_jour, by = "word") %>%
  mutate(tf_idf = tf * idf)

## document-bigram comparison --------------------------------------------------
data_base <- data_wos_base %>%
  select(id, TI, DE, ID, AB) %>%
  gather(value = text, key = type, -id) %>%
  mutate(text = str_replace_all(text, "[:digit:]", " ")) %>%
  mutate(text = str_replace_all(text, "[:punct:]", " ")) %>%
  mutate(text = str_squish(text)) %>%
  select(-type) %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  filter(!is.na(bigram)) %>%
  separate(bigram, c("w1", "w2"), remove = FALSE) %>%
  filter(!(w1 %in% stop_words$word) & !(w2 %in% stop_words$word)) %>%
  group_by(id) %>%
  count(bigram) %>%
  mutate(tot = sum(n)) %>%
  mutate(tf = n / tot) %>%
  ungroup()

data_jour <- data_wos_jour %>%
  select(id, TI, DE, ID, AB) %>%
  gather(value = text, key = type, -id) %>%
  mutate(text = str_replace_all(text, "[:digit:]", " ")) %>%
  mutate(text = str_replace_all(text, "[:punct:]", " ")) %>%
  mutate(text = str_squish(text)) %>%
  select(-type) %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  unique() %>%
  count(bigram) %>%
  rename(len_c_t = n) %>%
  mutate(len_c = length(unique(data_wos_jour$id))) %>%
  mutate(len_c_t = len_c_t + 1, len_c = len_c + 1) %>%
  mutate(idf = log(len_c / len_c_t))

# get tf-idf values
data_docbig <- data_base %>%
  left_join(data_jour, by = "bigram") %>%
  mutate(tf_idf = tf * idf)

# extract key information ------------------------------------------------------

## document-word information ---------------------------------------------------
summary(data_docwrd$tf_idf)
tmp_wrd <- data_docwrd %>%
  filter(tf_idf >= quantile(data_docwrd$tf_idf, 0.75, na.rm = TRUE)) %>%
  count(word) %>%
  arrange(desc(n))
png("Plots/wordcloud_word.png", width = 10, height = 10, units = "in", res = 600)
wordcloud(tmp_wrd$word[1:50], tmp_wrd$n[1:50], scale = c(2, .5), rot.per = 0.5)
dev.off()

## document-bigram information -------------------------------------------------
summary(data_docbig$tf_idf)
tmp_big <- data_docbig %>%
  filter(tf_idf >= quantile(data_docbig$tf_idf, 0.75, na.rm = TRUE)) %>%
  count(bigram) %>%
  arrange(desc(n))
png("Plots/wordcloud_bigram.png", width = 10, height = 10, units = "in", res = 600)
wordcloud(tmp_big$bigram[1:50], tmp_big$n[1:50], scale = c(2, .5), rot.per = 0.5)
dev.off()

write_xlsx(list("word" = tmp_wrd, "bigram" = tmp_big), path = file.path(dir_output, "base_term_frequencies.xlsx"))
