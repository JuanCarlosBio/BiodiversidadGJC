#!/usr/bin/env Rscript

library(tidyverse)
library(exifr)
library(glue)

zip_files <- list.files("images/", pattern = "\\.zip$", full.names = TRUE)
lapply(zip_files, unzip, exdir = "images/")

files <- list.files("images/arthropoda/", 
                    full.names = TRUE)

exif_data <- read_exif(files)

exif_data %>%
    rename_all(tolower) %>%
    select(filename, gpsdatetime, gpsposition) %>%
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) %>%
    filter(filename != "NO CLASIFICADO") %>%
    separate_wider_delim(gpsposition, delim = " ",
                         names = c("latitude", "longitude")) %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("specie", "family", "order", "phylo", 
                                   "endemic_genus", "endemic_specie")) %>%
    mutate(endemic_genus = case_when(endemic_genus == "end_gen_no" ~ FALSE,
                                     endemic_genus == "end_gen_si" ~ TRUE),
           endemic_specie = case_when(endemic_specie == "end_esp_no" ~ FALSE,
                                      endemic_specie == "end_esp_si" ~ TRUE)) %>%
    write_tsv("data/coord_species.tsv")
