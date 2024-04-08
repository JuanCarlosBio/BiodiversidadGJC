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

t_replacement <- c("_ta_" = "á","_te_" = "é","_ti_" = "í", "_to_" = "ó", "_tu_" = "ú", "_enie_" = "ñ")

exif_data_ai %>%
    rename_all(tolower) %>%
    select(filename, gpsdatetime, gpsposition) %>%
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO")) & str_detect(filename, "^AI")) %>% 
    separate_wider_delim(gpsposition, delim = " ",
                         names = c("latitude", "longitude")) %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", 
                                   "author","name", "family", 
                                   "order", "class", 
                                   "phylo", "domain", 
                                   "endemic_genus", "endemic_specie")) %>% 
    mutate(endemic_genus = case_when(endemic_genus == "end_gen_no" ~ "NO",
                                     endemic_genus == "end_gen_si" ~ "SI",
                                     endemic_genus == "invasora" ~ "Invasora",
                                     endemic_genus == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
           endemic_specie = case_when(endemic_specie == "end_esp_no" ~ "NO",
                                      endemic_specie == "end_esp_si" ~ "SI",
                                      endemic_specie == "invasora" ~ "Invasora",
                                      endemic_specie == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
           name = str_replace_all(name, t_replacement),
           author = str_replace_all(author, t_replacement)) %>%    
    write_tsv("data/coord_invertebrates.tsv")

exif_data_fv %>%
    rename_all(tolower) %>%
    select(filename, gpsdatetime, gpsposition) %>%
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO")) & str_detect(filename, "^FV")) %>%
    separate_wider_delim(gpsposition, delim = " ",
                         names = c("latitude", "longitude")) %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", "author",
                                   "name", "family", "order", 
                                   "class", "subdivision", 
                                   "division", "domain", 
                                   "endemic_genus", "endemic_specie")) %>%
    mutate(endemic_genus = case_when(endemic_genus == "end_gen_no" ~ "NO",
                                     endemic_genus == "end_gen_si" ~ "SI",
                                     endemic_genus == "invasora" ~ "Invasora",
                                     endemic_genus == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
           endemic_specie = case_when(endemic_specie == "end_esp_no" ~ "NO",
                                      endemic_specie == "end_esp_si" ~ "SI",
                                      endemic_specie == "invasora" ~ "Invasora",
                                      endemic_specie == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
           name = str_replace_all(name, t_replacement),
           author = str_replace_all(author, t_replacement)) %>%
    write_tsv("data/coord_plantae.tsv")
