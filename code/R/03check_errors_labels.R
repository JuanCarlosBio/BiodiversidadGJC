#!/usr/bin/env Rscript

suppressMessages(suppressWarnings({
    library(tidyverse)
    library(exifr)
}))

print("==============================================================")
print(">>> THIS ARE THE ERRORS THAT YOU HAVE HAD IN PLANTAE THIS WEEK")
print("==============================================================")

read_tsv("data/raw_dropbox_links_plantae_content.tsv") %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO"))) %>% 
    select(filename) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", "author",
                                   "endemic_genus", "endemic_specie", "endemic_subspecie",
                                   "origin", "category", "habitat", "id_biota"),
    too_few = "debug",
    too_many = "debug") %>% 
    select(id, filename_ok, filename_pieces) %>%
    filter(filename_ok == FALSE)%>%
    as.data.frame()

print("==============================================================")
print(">>> THIS ARE THE ERRORS THAT YOU HAVE HAD IN METAZOA THIS WEEK")
print("==============================================================")

read_tsv("data/raw_dropbox_links_metazoa_content.tsv") %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO"))) %>% 
    select(filename) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", "author", 
                                   "endemic_genus", "endemic_specie", "endemic_subspecie",
                                   "origin", "category", "id_biota"),
    too_few = "debug",
    too_many = "debug") %>% 
    select(id, filename_ok, filename_pieces) %>%
    filter(filename_ok == FALSE) %>%
    as.data.frame()

