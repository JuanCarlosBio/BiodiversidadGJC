#!/usr/bin/env Rscript

library(tidyverse)
library(exifr)
library(glue)

#zip_flora <- list.files("images/", pattern = "\\.zip$", full.names = TRUE)
#lapply(zip_files, unzip, exdir = "images/especies")

unzip("images/flora_vascular.zip", exdir = "images/flora_vascular")
unzip("images/invertebrados.zip", exdir = "images/invertebrados")

ai_files <- list.files("images/invertebrados/", 
                    full.names = TRUE)
fv_files <- list.files("images/flora_vascular/", 
                    full.names = TRUE)

exif_data_ai <- read_exif(ai_files)
exif_data_fv <- read_exif(fv_files)

exif_data_ai %>%
    rename_all(tolower) %>%
    select(filename, gpsdatetime, gpsposition) %>%
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO")) & str_detect(filename, "invertebrata")) %>% 
    separate_wider_delim(gpsposition, delim = " ",
                         names = c("latitude", "longitude")) %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", 
                                   "author","name", "family", 
                                   "order", "class", 
                                   "phylo", "endemic_genus", 
                                   "endemic_specie", 
                                   "in_verte_brates", "reino")) %>% 
    select(-in_verte_brates, -reino) %>%
    mutate(endemic_genus = case_when(endemic_genus == "end_gen_no" ~ "NO",
                                     endemic_genus == "end_gen_si" ~ "SI",
                                     endemic_genus == "invasora" ~ "Invasora",
                                     endemic_genus == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
           endemic_specie = case_when(endemic_specie == "end_esp_no" ~ "NO",
                                      endemic_specie == "end_esp_si" ~ "SI",
                                      endemic_specie == "invasora" ~ "Invasora",
                                      endemic_specie == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
            name = str_replace_all(name, pattern = "_ta_", replacement = "á"),
            name = str_replace_all(name, pattern = "_te_", replacement = "é"),
            name = str_replace_all(name, pattern = "_ti_", replacement = "í"),
            name = str_replace_all(name, pattern = "_to_", replacement = "ó"),
            name = str_replace_all(name, pattern = "_tu_", replacement = "ú"),
            name = str_replace_all(name, pattern = "_enie_", replacement = "ñ"),
            author = str_replace_all(author, pattern = "_ta_", replacement = "á"),
            author = str_replace_all(author, pattern = "_te_", replacement = "é"),
            author = str_replace_all(author, pattern = "_ti_", replacement = "í"),
            author = str_replace_all(author, pattern = "_to_", replacement = "ó"),
            author = str_replace_all(author, pattern = "_tu_", replacement = "ú"),
            author = str_replace_all(author, pattern = "_enie_", replacement = "ñ")) %>%
    write_tsv("data/coord_invertebrates.tsv")

exif_data_fv %>%
    rename_all(tolower) %>%
    select(filename, gpsdatetime, gpsposition) %>%
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) %>%
    filter(filename != "NO CLASIFICADO" & str_detect(filename, "plantae")) %>%
    separate_wider_delim(gpsposition, delim = " ",
                         names = c("latitude", "longitude")) %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", "author",
                                   "name", "family", "order", 
                                   "class", "subdivision", 
                                   "division", "endemic_genus", 
                                   "endemic_specie", "reino")) %>%
    mutate(endemic_genus = case_when(endemic_genus == "end_gen_no" ~ "NO",
                                     endemic_genus == "end_gen_si" ~ "SI",
                                     endemic_genus == "invasora" ~ "Invasora",
                                     endemic_genus == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
           endemic_specie = case_when(endemic_specie == "end_esp_no" ~ "NO",
                                      endemic_specie == "end_esp_si" ~ "SI",
                                      endemic_specie == "invasora" ~ "Invasora",
                                      endemic_specie == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
            name = str_replace_all(name, pattern = "_ta_", replacement = "á"),
            name = str_replace_all(name, pattern = "_te_", replacement = "é"),
            name = str_replace_all(name, pattern = "_ti_", replacement = "í"),
            name = str_replace_all(name, pattern = "_to_", replacement = "ó"),
            name = str_replace_all(name, pattern = "_tu_", replacement = "ú"),
            name = str_replace_all(name, pattern = "_enie_", replacement = "ñ"),
            author = str_replace_all(author, pattern = "_ta_", replacement = "á"),
            author = str_replace_all(author, pattern = "_te_", replacement = "é"),
            author = str_replace_all(author, pattern = "_ti_", replacement = "í"),
            author = str_replace_all(author, pattern = "_to_", replacement = "ó"),
            author = str_replace_all(author, pattern = "_tu_", replacement = "ú"),
            author = str_replace_all(author, pattern = "_enie_", replacement = "ñ")) %>%
    select(-reino) %>%
    write_tsv("data/coord_plantae.tsv")
