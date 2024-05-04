#!/usr/bin/env Rscript

library(tidyverse)
library(gt)
library(glue)

invertebrates <- read_tsv("data/coord_invertebrates.tsv")
plantae <- read_tsv("data/coord_plantae.tsv") 

url_biota <- "https://www.biodiversidadcanarias.es/biota/especie/"

table_invertebrates <- invertebrates %>%
    drop_na(author) %>%
    mutate(name = ifelse(is.na(name), "-", as.character(name)),
           phylo = str_to_upper(phylo),
           class = str_to_upper(class),
           family = str_to_title(family)) %>%
    group_by(specie, author, name,
             family, class, phylo,  
             endemic_genus, endemic_specie, endemic_subspecie, 
             origin, category, id_biota) %>%
    count() %>%
    arrange(phylo, class, family, specie) %>%
    select(-n)

gt_invertebrates <- table_invertebrates %>% 
    as_tibble() %>% 
    mutate(id_biota = glue("[Link Biota {id_biota}]({url_biota}{id_biota})"),
           id_biota = map(id_biota, md)) %>%
    group_by(phylo, class) %>%
    gt() %>%
    cols_align(
        align = "center"
    ) %>%
    tab_header(
        title = md("**Tabla de las especies de invertebrados**")
    ) %>%
    cols_label(
        specie = "Especie",
        author = "Autor",
        name = "Nombre común",
        family = "Familia",
        endemic_genus = "Endemismo\n(Género)",
        endemic_specie = "Endemismo\n(Especie)", 
        endemic_subspecie = "Endemismo\n(Subespecie)", 
        origin = "Origen",
        category = "Categoría",
        id_biota = "Link Biota",
    ) %>%
    tab_options(
        table.background.color = "#fff3d8"
    ) %>%
    opt_interactive(
        use_search = TRUE
    )

table_plantae <- plantae %>%
    drop_na(author) %>%
    mutate(name = ifelse(is.na(name), "-", as.character(name)),
           division = str_to_upper(division),
           class = str_to_upper(class),
           family = str_to_title(family)) %>%
    group_by(specie, author, name,
             family, class, division,  
             endemic_genus, endemic_specie, endemic_subspecie, 
             origin, category, id_biota) %>%
    count() %>%
    arrange(division, class, family, specie) %>%
    select(-n)

gt_plantae <- table_plantae %>% 
    as_tibble() %>% 
    mutate(id_biota = glue("[Link Biota {id_biota}]({url_biota}{id_biota})"),
           id_biota = map(id_biota, md)) %>%
    group_by(division, class) %>%
    gt() %>%
    cols_align(
        align = "center"
    ) %>%
    tab_header(
        title = md("**Tabla de las especies de invertebrados**")
    ) %>%
    cols_label(
        specie = "Especie",
        author = "Autor",
        name = "Nombre común",
        family = "Familia",
        endemic_genus = "Endemismo\n(Género)",
        endemic_specie = "Endemismo\n(Especie)", 
        endemic_subspecie = "Endemismo\n(Subespecie)", 
        origin = "Origen",
        category = "Categoría",
        id_biota = "Link Biota",
    ) %>%
    tab_options(
        table.background.color = "#fff3d8"
    ) %>%
    opt_interactive(
        use_search = TRUE
    )
