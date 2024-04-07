library(tidyverse)

flora_vascular <- list.files("images/flora_vascular", full.names = TRUE)

read_exif(flora_vascular) %>%
    select(FileName) %>%
    print(n=Inf)

read_exif(flora_vascular) %>%
    rename_all(tolower) %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO"))) %>% 
    select(filename) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", 
                                   "author","name", "family", 
                                   "order", "class", 
                                   "phylo", "endemic_genus", 
                                   "endemic_specie", 
                                   "in_verte_brates", "reino"),
    too_few = "debug",
    too_many = "debug") %>% 
    select(id, filename_ok, filename_pieces) %>%
    filter(filename_ok == FALSE)

