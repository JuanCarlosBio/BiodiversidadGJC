#!/usr/bin/env Rscript

library(tidyverse)
library(gt)
library(glue)

#----------------------------------------------------------------------#
# Reading the data of the Speciecies of Invertebrates and Plantae
#----------------------------------------------------------------------#
invertebrates <- read_tsv("data/coord_invertebrates.tsv")
plantae <- read_tsv("data/coord_plantae.tsv") 

# Url for finding the species in biota https://www.biodiversidadcanarias.es/biota/
url_biota <- "https://www.biodiversidadcanarias.es/biota/especie/"

#----------------------------------------------------------------------#
# Processing the data 
#----------------------------------------------------------------------#
table_invertebrates <- invertebrates %>%
    drop_na(author) %>%
    mutate(name = ifelse(is.na(name), "-", as.character(name)),
           phylo = str_to_title(phylo),
           class = str_to_title(class),
           family = str_to_title(family)) %>%
    group_by(specie, author, name,
             family, class, phylo,  
             endemic_genus, endemic_specie, endemic_subspecie, 
             origin, category, id_biota) %>%
    count() %>%
    arrange(phylo, class, family, specie) %>%
    select(-n)

table_plantae <- plantae %>%
    drop_na(author) %>%
    mutate(name = ifelse(is.na(name), "-", as.character(name)),
           division = str_to_title(division),
           class = str_to_title(class),
           family = str_to_title(family)) %>%
    group_by(specie, author, name,
             family, class, division,  
             endemic_genus, endemic_specie, endemic_subspecie, 
             origin, category, id_biota) %>%
    count() %>%
    arrange(division, class, family, specie) %>%
    select(-n)

#----------------------------------------------------------------------#
#  Making the tables of the species CLASSIFIED
#----------------------------------------------------------------------#
gt_invertebrates <- table_invertebrates %>% 
    as_tibble() %>% 
    mutate(id_biota = glue("[Link Biota {id_biota}]({url_biota}{id_biota})"),
           id_biota = map(id_biota, md)) %>%
    gt() %>%
    cols_align(
        align = "center"
    ) %>%
    tab_header(
        title = md("**Tabla de las especies de invertebrados**")
    ) %>%
    cols_label(
        specie = md("**ESPECIE**"),
        author = md("**AUTOR**"),
        name = md("**NOMBRE COMÚN**"),
        family = md("**FAMILIA**"),
        class = md("**CLASE**"),
        phylo = md("**FILO**"),
        endemic_genus = md("**ENDEMISMO<br>GÉNERO**"),
        endemic_specie = md("**ENDEMISMO<br>ESPECIE**"), 
        endemic_subspecie = md("**ENDEMISMO<br>SUBESPECIE**"), 
        origin = md("**ORIGEN**"),
        category = md("**CATEGORÍA**"),
        id_biota = md("**LINK BIOTA**"),
    ) %>%
    tab_options(
        table.background.color = "#fff3d8"
    ) %>% 
    opt_stylize(
        color = "blue"
    ) %>%
    opt_interactive(
        use_search = TRUE,
        use_resizers = TRUE,
        use_compact_mode = TRUE
    )

gt_plantae <- table_plantae %>% 
    as_tibble() %>% 
    mutate(id_biota = glue("[Link Biota {id_biota}]({url_biota}{id_biota})"),
           id_biota = map(id_biota, md)) %>%
    gt() %>%
    cols_align(
        align = "center"
    ) %>%
    tab_header(
        title = md("**Tabla de las especies de invertebrados**")
    ) %>%
    cols_label(
        specie = md("**ESPECIE**"),
        author = md("**AUTOR**"),
        name = md("**NOMBRE COMÚN**"),
        family = md("**FAMILIA**"),
        class = md("**CLASE**"),
        division = md("**DIVISION**"),
        endemic_genus = md("**ENDEMISMO<br>GÉNERO**"),
        endemic_specie = md("**ENDEMISMO<br>ESPECIE**"), 
        endemic_subspecie = md("**ENDEMISMO<br>SUBESPECIE**"), 
        origin = md("**ORIGEN**"),
        category = md("**CATEGORÍA**"),
        id_biota = md("**LINK BIOTA**"),
    ) %>%
    tab_options(
        table.background.color = "#fff3d8"
    ) %>%
    opt_stylize(
        color = "blue"
    ) %>%
    opt_interactive(
        use_search = TRUE,
        use_resizers = TRUE,
        use_compact_mode = TRUE
    )
