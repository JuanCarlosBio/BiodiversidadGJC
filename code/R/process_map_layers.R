#!/usr/bin/env Rscript

## Load the libraries
suppressMessages(suppressWarnings({
    library(leaflet)
    library(sf)
    library(tidyverse)
    library(geojsonio)
    library(leaflet.extras)
    library(glue)
    library(crosstalk)
}))

url_biota <- "https://www.biodiversidadcanarias.es/biota/especie/"

## Load the data
# Url for finding the species in biota https://www.biodiversidadcanarias.es/biota/

f_species <- function(data){
    df_speices <- read_tsv(glue("data/{data}")) |>
        mutate(family = str_to_title(family),
            order = str_to_title(order),
            class = str_to_title(class), 
            division = str_to_title(division)) 

    return(df_speices)
}

enp_map <- read_sf("data/gran_canaria_shp/gc_pne.shp") |>
  st_transform(map, crs = 4326) |>
  mutate(categoria = factor(categoria,
                            levels = c("Monumento Natural", 
                                       "Paisaje Protegido",
                                       "Parque Natural", 
                                       "Parque Rural", 
                                       "Reserva Natural Especial",
                                       "Reserva Natural Integral", 
                                       "Sitio de Interés Científico")))

protected_species <- read_sf("data/gran_canaria_shp/protected_species_layer.shp") |>
  group_by(specie, name, id_biota, geometry) |> 
  summarise(n = n()) |>  
  ungroup() |>
  group_by(geometry) |>
  summarise(species = paste0(glue("<i><a href='https://www.biodiversidadcanarias.es/biota/especie/{id_biota}'>{specie}</i></a> ({name})"), collapse = "<br>> "),
            n = n())

zec_map <- read_sf("data/gran_canaria_shp/gc_zec.shp") |> 
  rename_all(tolower) |>
  st_transform(map, crs = 4326) 

hic_map <- read_sf("data/gran_canaria_shp/gc_hic.shp") |> 
  rename_all(tolower) |> 
  mutate(
    name = case_when(
      habue4dva1 == "1150" ~ "*Lagunas costeras",
      habue4dva1 == "1210" ~ "Vegetación anual sobre desechos marinos acumulados",
      habue4dva1 == "1250" ~ "Acantilados con vegetación endémica de las costas macaronésicas",
      habue4dva1 == "1420" ~ "Matorrales halófilos mediterráneos y termoaltlánticos (Sarcocornietea fruticosae)",
      habue4dva1 == "2110" ~ "Dunas móviles embrionarias",
      habue4dva1 == "2120" ~ "Dunas móviles de litoral con Ammophila arenaria (dunas blancas)",
      habue4dva1 == "2130" ~ "*Dunas costeras fijas con vegetación herbácea (dunas grises)",
      habue4dva1 == "4050" ~ "*Brezales macaronésicos endémicos",
      habue4dva1 == "4090" ~ "Matorrales oromediterráneos endémicos con aliaga",
      habue4dva1 == "5330" ~ "Matorrales termomediterráneos y preestépicos",
      habue4dva1 == "6420" ~ "Prados húmedos mediterráneos de hierbas altas del Molinio-Holoschoenion",
      habue4dva1 == "8220" ~ "Pendientes rocosas silíceas con vegetación casmofítica",
      habue4dva1 == "8320" ~ "Campos de lava y excavaciones naturales",
      habue4dva1 == "92D0" ~ "Galerías y matorrales ribereños meridionales (Nerio-Tamaricetea y Securinegion tinctoriae)",
      habue4dva1 == "9320" ~ "Bosques de Olea y Ceratonia",
      habue4dva1 == "9360" ~ "*Bosques de laureles macaronésicos (Laurus, Ocotea)",
      habue4dva1 == "9370" ~ "*Palmerales de Phoenix",
      habue4dva1 == "9550" ~ "Bosques de pino endémico canario",
      habue4dva1 == "9560" ~ "*Bosques endémicos de Juniperus spp.",
    ),
    habue4dva1 = factor(habue4dva1,
                        levels = c("1150", "1210", "1250", "1420", "2110", "2120", "2130", "4050", "4090", "5330", "6420",
                                   "8220", "8320", "92D0", "9320", "9360", "9370", "9550", "9560")) 
  ) |> 
  st_transform(map, crs = 4326) |>
  filter(habue4dva1 != "NA")



jardin_botanico <- read_sf("data/gran_canaria_shp/jardin_botanico.shp")

## Create the color palettes for the layers
pal_pne <- colorFactor(
  palette = c("#004078", "#80a0bd", "#f78000", "#e60000", "#00913f", "#034a31", "#BADBCA"),
  domain = enp_map$categoria
)

pal_hic <- colorFactor(
  palette = c("#0d0081", "#c2fbfe", "#3134fe", "#00ffff", "#fef9cd", "#ffff00", "#dbcd00", 
              "#a5fea4", "#a24eac", "#e85858", "#f7c2fe", "#646464", "#d2d2d2", "#f6a4fe", 
              "#ca9265", "#00ff00", "#febe00", "#016300", "#a06632"),
  domain = hic_map$habue4dva1
)
