#!/usr/bin/env Rscript

library(tidyverse)
library(exifr)
library(glue)

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
    select(filename, gpsdatetime, gpsposition,gpsaltitude) %>%
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO")) & str_detect(filename, "^AI")) %>% 
    separate_wider_delim(gpsposition, delim = " ",
                         names = c("latitude", "longitude")) %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", "author","name", 
                                   "family", "order", "class", "phylo", "domain", 
                                   "endemic_genus", "endemic_specie", "endemic_subspecie",
                                   "origin", "category", "id_biota")) %>% 
    mutate(endemic_genus = case_when(endemic_genus == "eg_no" ~ "NO",
                                     endemic_genus == "eg_si" ~ "SI",
                                     !(endemic_subspecie == "eg_no") | !(endemic_subspecie == "eg_no") ~ "-"),
           endemic_specie = case_when(endemic_specie == "ee_no" ~ "NO",
                                      endemic_specie == "ee_si" ~ "SI",
                                      !(endemic_subspecie == "ee_no") | !(endemic_subspecie == "ee_no") ~ "-"),
           endemic_subspecie = case_when(endemic_subspecie == "es_no" ~ "NO",
                                         endemic_subspecie == "es_si" ~ "SI",
                                         !(endemic_subspecie == "es_no") | !(endemic_subspecie == "es_no") ~ "-"),
           origin = case_when(origin == "ns" ~ "Nativo seguro", origin == "np" ~ "Nativo probable", 
                              origin == "isi" ~ "Introducido seguro invasor", origin == "isn" ~ "Introducido seguro no invasor", 
                              origin == "ip" ~ "Introducido probable"),
           category = case_when(category == "ep" ~ "Especie protegida",
                                category == "ei" ~ "Especie introducida",
                                !(category == "ep") | !(category == "ei") ~ "-"),
           name = str_replace_all(name, t_replacement),
           author = str_replace_all(author, t_replacement)) %>% 
    write_tsv("data/coord_invertebrates.tsv")


exif_data_fv %>%
    rename_all(tolower) %>%
    select(filename, gpsdatetime, gpsposition, gpsaltitude) %>%
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO")) & str_detect(filename, "^FV")) %>%
    separate_wider_delim(gpsposition, delim = " ",
                         names = c("latitude", "longitude")) %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", "author", "name", "family", 
                                   "order", "class", "division",
                                   "endemic_genus", "endemic_specie", "endemic_subspecie",
                                   "origin", "category", "habitat", "id_biota")) %>%
    mutate(domain = "plantae",
           endemic_genus = case_when(endemic_genus == "eg_no" ~ "NO",
                                     endemic_genus == "eg_si" ~ "SI",
                                     !(endemic_genus == "eg_no") | !(endemic_genus == "eg_no") ~ "-"),
           endemic_specie = case_when(endemic_specie == "ee_no" ~ "NO",
                                      endemic_specie == "ee_si" ~ "SI",
                                      !(endemic_specie == "ee_no") | !(endemic_specie == "ee_no") ~ "-"),
           endemic_subspecie = case_when(endemic_subspecie == "es_no" ~ "NO",
                                         endemic_subspecie == "es_si" ~ "SI",
                                         !(endemic_subspecie == "es_no") | !(endemic_subspecie == "es_no") ~ "-"),
           origin = case_when(origin == "ns" ~ "Nativo seguro", origin == "np" ~ "Nativo probable", 
                              origin == "isi" ~ "Introducido seguro invasor", origin == "isn" ~ "Introducido seguro no invasor", 
                              origin == "ip" ~ "Introducido probable"),
           category = case_when(category == "ep" ~ "Especie protegida",
                                category == "ei" ~ "Especie introducida",
                                !(endemic_subspecie == "ep") | !(endemic_subspecie == "ei") ~ "-"),    
           name = str_replace_all(name, t_replacement),
           author = str_replace_all(author, t_replacement)) %>% 
    write_tsv("data/coord_plantae.tsv")
