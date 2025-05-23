#!/usr/bin/env Rscript

suppressMessages(suppressWarnings({
    library(tidyverse)
    library(gt)
    library(glue)
}))

#----------------------------------------------------------------------#
# Reading the data of the Speciecies of Invertebrates and Plantae
#----------------------------------------------------------------------#
# invertebrates <- read_tsv("data/species/processed/coord_invertebrates.tsv")
# plantae <- read_tsv("data/species/processed/coord_plantae.tsv") 
species <- read_tsv("data/species/processed/coord_species.tsv")

# Url for finding the species in biota https://www.biodiversidadcanarias.es/biota/
url_biota <- "https://www.biodiversidadcanarias.es/biota/especie/"

#----------------------------------------------------------------------#
# Processing the data 
#----------------------------------------------------------------------#
## Antes tenía separado las especies de animales y plantas
# table_invertebrates <- invertebrates %>%
#     drop_na(scientific_name) %>%
#     mutate(name = ifelse(is.na(name), "-", as.character(name)),
#            class = str_to_title(class)) %>%
#     group_by(scientific_name, name, id_biota, family,
#              endemicity, origin, category) %>%
#     count() %>%
#     arrange(scientific_name, family) %>%
#     select(-n)
# 
# table_plantae <- plantae %>%
#     drop_na(scientific_name) %>%
#     mutate(name = ifelse(is.na(name), "-", as.character(name)),
#            division = str_to_title(division)) %>%
#     group_by(scientific_name, name, id_biota, family,
#              endemicity, origin, category) %>%
#     count() %>%
#     arrange(scientific_name, family) %>%
#     select(-n)

table_species <- species %>%
    drop_na(scientific_name) %>%
    mutate(name = ifelse(is.na(name), "-", as.character(name)),
           division = str_to_title(division)) %>%
    group_by(scientific_name, name, id_biota, family,
             endemicity, origin, category) %>%
    count() %>%
    arrange(scientific_name, family) %>%
    select(-n)

#----------------------------------------------------------------------#
#  Making the tables of the species CLASSIFIED
#----------------------------------------------------------------------#
# gt_invertebrates <- table_invertebrates %>% 
#     as_tibble() %>% 
#     mutate(id_biota = glue("[Link Biota {id_biota}]({url_biota}{id_biota})"),
#            id_biota = map(id_biota, md),
#            scientific_name = map(glue("*{scientific_name}*"), md)) %>%
#     gt() %>%
#     cols_align(
#         align = "center"
#     ) %>%
#     tab_header(
#         title = md("**Tabla de las especies de invertebrados**")
#     ) %>%
#     cols_label(
#         scientific_name = md("**ESPECIE**"),
#         name = md("**NOMBRE COMÚN**"),
#         family = md("**FAMILIA**"),
#         id_biota = md("**LINK BIOTA**"),
#         endemicity = md("**ENDEMICIDAD**"),
#         origin = md("**ORIGEN**"),
#         category = md("**CATEGORÍA**"),
#     ) %>%
#     tab_options(
#         table.background.color = "#fff3d8"
#     ) %>% 
#     opt_stylize(
#     ) %>%
#     opt_interactive(
#     use_search = TRUE,
#     use_filters = TRUE,
#     use_resizers = TRUE,
#     use_highlight = TRUE,
#     use_compact_mode = TRUE,
#     use_text_wrapping = FALSE,
#     use_page_size_select = TRUE
#     ) 
# 
# gt_plantae <- table_plantae %>% 
#     as_tibble() %>% 
#     mutate(id_biota = glue("[Link Biota {id_biota}]({url_biota}{id_biota})"),
#            id_biota = map(id_biota, md),
#            scientific_name = map(glue("*{scientific_name}*"), md)) %>%
#     gt() %>%
#     cols_align(
#         align = "center"
#     ) %>%
#     tab_header(
#         title = md("**Tabla de las especies de invertebrados**")
#     ) %>%
#     cols_label(
#         scientific_name = md("**ESPECIE**"),
#         name = md("**NOMBRE COMÚN**"),
#         family = md("**FAMILIA**"),
#         id_biota = md("**LINK BIOTA**"),
#         endemicity = md("**ENDEMICIDAD**"),
#         origin = md("**ORIGEN**"),
#         category = md("**CATEGORÍA**"),
#     ) %>%
#     tab_options(
#         table.background.color = "#fff3d8"
#     ) %>%
#     opt_stylize(
#         color = "blue"
#     ) %>%
#     opt_interactive(
#     use_search = TRUE,
#     use_filters = TRUE,
#     use_resizers = TRUE,
#     use_highlight = TRUE,
#     use_compact_mode = TRUE,
#     use_text_wrapping = FALSE,
#     use_page_size_select = TRUE
#     )

gt_species <- table_species %>% 
    as_tibble() %>% 
    mutate(id_biota = glue("[Link Biota {id_biota}]({url_biota}{id_biota})"),
           id_biota = map(id_biota, md),
           scientific_name = map(glue("*{scientific_name}*"), md)) %>%
    gt() %>%
    cols_align(
        align = "center"
    ) %>%
    tab_header(
        title = md("**Tabla de las especies de invertebrados**")
    ) %>%
    cols_label(
        scientific_name = md("**ESPECIE**"),
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
    use_filters = TRUE,
    use_resizers = TRUE,
    use_highlight = TRUE,
    use_compact_mode = TRUE,
    use_text_wrapping = FALSE,
    use_page_size_select = TRUE
    )
