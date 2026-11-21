#!/usr/bin/env Rscript

suppressMessages(suppressWarnings({
    library(tidyverse)
    library(gt)
    library(glue)
}))

#----------------------------------------------------------------------#
# Reading the data of the Speciecies of Invertebrates and Plantae
#----------------------------------------------------------------------#

species <- read_csv("data/species/processed/species_data_base.csv")

# Url for finding the species in biota https://www.biodiversidadcanarias.es/biota/

url_biota <- "https://www.biodiversidadcanarias.es/biota/especie/"

#----------------------------------------------------------------------#
# Processing the data 
#----------------------------------------------------------------------#

table_species <- species %>%
    drop_na(scientific_name) %>%
    mutate(name = ifelse(is.na(name), "-", as.character(name)),
           division = str_to_title(division)) %>%
    group_by(scientific_name, name, id_biota, family,
             endemicity, origin, isla_muni) %>%
    count() %>%
    arrange(scientific_name, family) %>%
    select(-n)

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
        title = md("**Tabla de las especies de especies**")
    ) %>%
    cols_label(
        scientific_name = md("**ESPECIE**"),
        name = md("**NOMBRE COMÚN**"),
        family = md("**FAMILIA**"),
        id_biota = md("**LINK BIOTA**"),
        endemicity = md("**ENDEMICIDAD**"),
        origin = md("**ORIGEN**"),
        isla_muni = md("**ISLA**"),
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
