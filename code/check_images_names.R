library(tidyverse)

flora_vascular <- list.files("images/flora_vascular", full.names = TRUE)
invertebrados <- list.files("images/invertebrados", full.names = TRUE)

read_exif(flora_vascular) %>%
    select(FileName) %>%
    print(n=Inf) %>%
    as.vector()

read_exif(invertebrados) %>%
    select(FileName) %>%
    print(n=Inf) %>%
    as.vector()

read_exif(flora_vascular) %>%
    rename_all(tolower) %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO"))) %>% 
    select(filename) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", "author",
                                   "name", "family", "order", 
                                   "class", "subdivision", 
                                   "division", "domain", 
                                   "endemic_genus", "endemic_specie"),
    too_few = "debug",
    too_many = "debug") %>% 
    select(id, filename_ok, filename_pieces) %>%
    filter(filename_ok == FALSE)%>%
    print(n=Inf)

read_exif(invertebrados) %>%
    rename_all(tolower) %>%
    filter(!(str_detect(filename,  "NO CLASIFICADO"))) %>% 
    select(filename) %>%
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", 
                                   "author","name", "family", 
                                   "order", "class", 
                                   "phylo", "domain", 
                                   "endemic_genus", "endemic_specie"),
    too_few = "debug",
    too_many = "debug") %>% 
    select(id, filename_ok, filename_pieces) %>%
    filter(filename_ok == FALSE) %>%
    print(n=Inf)

