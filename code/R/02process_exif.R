#!/usr/bin/env Rscript

suppressMessages(suppressWarnings({
    library(dplyr)
    library(readr)
    library(tidyr)
    library(stringr)
    library(lubridate)
}))

## -> Ahora que lo vuelvo a visitar a día de 18/11/2024 digo que este código funciona 
## de maravilla a pesar de ser BASURA xd, tengo pensado como solucionar esta locura 
## pero necesito tiempo para mentalizarme en cambiar este desastre

data_biota <- readr::read_tsv("data/biota_data_processed.tsv")
protected_species_layer <- readr::read_tsv("data/protected_species/coord_plantae_pe.tsv")

t_replacement <- c("_ta_" = "á","_te_" = "é","_ti_" = "í", "_to_" = "ó", "_tu_" = "ú", "_enie_" = "ñ") ## -> pero esto que es! en que estaba pensando, bueno estas cosas pasan

read_tsv("data/raw_dropbox_links_metazoa_content.tsv") |>
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) |>
    filter(!(str_detect(filename,  "NO CLASIFICADO")) & 
           str_detect(filename, "^AI") & 
           str_count(filename, "-") == 8
           ) |> 
    separate_wider_delim(gpsposition, delim = " ", names = c("latitude", "longitude")) |>
    mutate(latitude = as.numeric(latitude), longitude = as.numeric(longitude)) |>
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", "author", 
                                   "endemic_genus", "endemic_specie", "endemic_subspecie",
                                   "origin", "category", "id_biota")) |>
    mutate(
	endemic_genus = case_when(
            endemic_genus == "eg_no" ~ "NO",
            endemic_genus == "eg_si" ~ "SI",
            !(endemic_subspecie == "eg_no") | !(endemic_subspecie == "eg_no") ~ "-"
	    ),
        endemic_specie = case_when(
	    endemic_specie == "ee_no" ~ "NO",
            endemic_specie == "ee_si" ~ "SI",
            !(endemic_subspecie == "ee_no") | !(endemic_subspecie == "ee_no") ~ "-"
	    ),
        endemic_subspecie = case_when(
	    endemic_subspecie == "es_no" ~ "NO",
            endemic_subspecie == "es_si" ~ "SI",
            !(endemic_subspecie == "es_no") | !(endemic_subspecie == "es_no") ~ "-"
	    ),
        origin = case_when(
	    origin == "ns" ~ "Nativo seguro", origin == "np" ~ "Nativo probable", 
            origin == "isi" ~ "Introducido seguro invasor", origin == "isn" ~ "Introducido seguro no invasor", 
            origin == "ip" ~ "Introducido probable"
	    ),
        category = case_when(
	    category == "ep" ~ "Especie protegida",
            category == "ei" ~ "Especie introducida",
            !(category == "ep") | !(category == "ei") ~ "Especie nativa"
	    ),
        author = str_replace_all(author, t_replacement),
        gpsdatetime = ymd_hms(gpsdatetime),
        gpsdatetime = format(gpsdatetime, "%d/%m/%Y")) |> 
    inner_join(data_biota, ., by="id_biota") |> 
    select(-subdivision, division) |>
    readr::write_tsv("data/coord_invertebrates.tsv")


read_tsv("data/raw_dropbox_links_plantae_content.tsv") |>
    mutate(filename = str_replace(filename, pattern = ".jpg", replacement = "")) |>
    filter(!(str_detect(filename,  "NO CLASIFICADO")) & 
           str_detect(filename, "^FV"),
           str_count(filename, "-") == 9) |>
    separate_wider_delim(gpsposition, delim = " ", names = c("latitude", "longitude")) |>
    mutate(latitude = as.numeric(latitude), longitude = as.numeric(longitude)) |>
    separate_wider_delim(filename, delim = "-",
                         names = c("id", "specie", "author",
                                   "endemic_genus", "endemic_specie", "endemic_subspecie",
                                   "origin", "category", "habitat", "id_biota")) |>
    mutate(
	endemic_genus = case_when(
            endemic_genus == "eg_no" ~ "NO",
            endemic_genus == "eg_si" ~ "SI",
            !(endemic_genus == "eg_no") | !(endemic_genus == "eg_no") ~ "-"
	    ),
        endemic_specie = case_when(
	    endemic_specie == "ee_no" ~ "NO",
            endemic_specie == "ee_si" ~ "SI",
            !(endemic_specie == "ee_no") | !(endemic_specie == "ee_no") ~ "-"
	    ),
        endemic_subspecie = case_when(
	    endemic_subspecie == "es_no" ~ "NO",
            endemic_subspecie == "es_si" ~ "SI",
            !(endemic_subspecie == "es_no") | !(endemic_subspecie == "es_no") ~ "-"
	    ),
        origin = case_when(
	    origin == "ns" ~ "Nativo seguro", origin == "np" ~ "Nativo probable", 
            origin == "isi" ~ "Introducido seguro invasor", origin == "isn" ~ "Introducido seguro no invasor", 
            origin == "ip" ~ "Introducido probable"
	    ),
        category = case_when(
	    category == "ep" ~ "Especie protegida",
            category == "ei" ~ "Especie introducida",
            category == "et" ~ "Especie traslocada",
            !(endemic_subspecie == "ep") | !(endemic_subspecie == "ei") ~ "Especie nativa"
	    ),
        author = str_replace_all(author, t_replacement),
        specie = str_replace_all(specie, pattern = "_", replacement = "-"),
        gpsdatetime = ymd_hms(gpsdatetime),
        gpsdatetime = format(gpsdatetime, "%d/%m/%Y")) |> 
    inner_join(data_biota, ., by="id_biota") |> 
    select(-subdivision, division) |> 
    bind_rows(protected_species_layer) |> 
    readr::write_tsv("data/coord_plantae.tsv")
