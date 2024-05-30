#!/usr/bin/env Rscript

suppressMessages(suppressWarnings({
    library(tidyverse)
    library(gt)
    library(glue)
}))

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
           class = str_to_title(class)) %>%
    group_by(specie, author, name, id_biota, family,
             endemicity, origin, category) %>%
    count() %>%
    arrange(specie, family) %>%
    select(-n)

table_plantae <- plantae %>%
    drop_na(author) %>%
    mutate(name = ifelse(is.na(name), "-", as.character(name)),
           division = str_to_title(division)) %>%
    group_by(specie, author, name, id_biota, family,
             endemicity, origin, category) %>%
    count() %>%
    arrange(specie, family) %>%
    select(-n)

#----------------------------------------------------------------------#
#  Making the tables of the species CLASSIFIED
#----------------------------------------------------------------------#
gt_invertebrates <- table_invertebrates %>% 
    as_tibble() %>% 
    mutate(id_biota = glue("[Link Biota {id_biota}]({url_biota}{id_biota})"),
           id_biota = map(id_biota, md),
           specie = map(glue("*{specie}*"), md)) %>%
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
        id_biota = md("**LINK BIOTA**"),
        endemicity = md("**ENDEMICIDAD**"),
        origin = md("**ORIGEN**"),
        category = md("**CATEGORÍA**"),
    ) %>%
    tab_options(
        table.background.color = "#fff3d8"
    ) %>% 
    opt_stylize(
    ) %>%
    opt_interactive(
        use_search = TRUE,
        use_resizers = TRUE,
        use_compact_mode = TRUE
    )

gt_plantae <- table_plantae %>% 
    as_tibble() %>% 
    mutate(id_biota = glue("[Link Biota {id_biota}]({url_biota}{id_biota})"),
           id_biota = map(id_biota, md),
           specie = map(glue("*{specie}*"), md)) %>%
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
        id_biota = md("**LINK BIOTA**"),
        endemicity = md("**ENDEMICIDAD**"),
        origin = md("**ORIGEN**"),
        category = md("**CATEGORÍA**"),
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
