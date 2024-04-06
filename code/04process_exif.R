#!/usr/bin/env Rscript

library(tidyverse)
library(exifr)
library(glue)

zip_files <- list.files("images/", pattern = "\\.zip$", full.names = TRUE)
lapply(zip_files, unzip, exdir = "images/especies")

files <- list.files("images/especies/", 
                    full.names = TRUE)

exif_data <- read_exif(files)

exif_data$GPSDateTime <- ymd_hms(gsub("Z", "", exif_data$GPSDateTime))

exif_data$id <- order(exif_data$GPSDateTime)

exif_data %>%
    rename_all(tolower) %>%
    select(id, filename, gpsdatetime, gpsposition) %>%
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO")) & str_detect(filename, "invertebrata")) %>% 
    separate_wider_delim(gpsposition, delim = " ",
                         names = c("latitude", "longitude")) %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("specie", "author",
                                   "family", "order", 
                                   "class", "phylo", 
                                   "endemic_genus", "endemic_specie",
                                   "in_verte_brates", "reino")) %>% 
    select(-in_verte_brates, -reino) %>%
    mutate(endemic_genus = case_when(endemic_genus == "end_gen_no" ~ "NO",
                                     endemic_genus == "end_gen_si" ~ "SI",
                                     endemic_genus == "invasora" ~ "Invasora",
                                     endemic_genus == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
           endemic_specie = case_when(endemic_specie == "end_esp_no" ~ "NO",
                                      endemic_specie == "end_esp_si" ~ "SI",
                                      endemic_specie == "invasora" ~ "Invasora",
                                      endemic_specie == "SIN CLASIFICAR" ~ "SIN CLASIFICAR")) %>%
    write_tsv("data/coord_invertebrates.tsv")

exif_data %>%
    rename_all(tolower) %>%
    select(id, filename, gpsdatetime, gpsposition) %>%
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) %>%
    filter(filename != "NO CLASIFICADO" & str_detect(filename, "plantae")) %>%
    separate_wider_delim(gpsposition, delim = " ",
                         names = c("latitude", "longitude")) %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("specie", "author",
                                   "family", "order", 
                                   "class", "subdivision", 
                                   "division", "endemic_genus", 
                                   "endemic_specie", "reino")) %>%
    select(-reino) %>%
    mutate(endemic_genus = case_when(endemic_genus == "end_gen_no" ~ "NO",
                                     endemic_genus == "end_gen_si" ~ "SI",
                                     endemic_genus == "invasora" ~ "Invasora",
                                     endemic_genus == "SIN CLASIFICAR" ~ "SIN CLASIFICAR"),
           endemic_specie = case_when(endemic_specie == "end_esp_no" ~ "NO",
                                      endemic_specie == "end_esp_si" ~ "SI",
                                      endemic_specie == "invasora" ~ "Invasora",
                                      endemic_specie == "SIN CLASIFICAR" ~ "SIN CLASIFICAR")) %>%
    write_tsv("data/coord_plantae.tsv")
