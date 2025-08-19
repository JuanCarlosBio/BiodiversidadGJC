#!/usr/bin/env Rscript

## CARGAR LAS LIBRERÍAS
##==============================================

## Librerías necesarias para el procesado de datos y mapas
suppressMessages(suppressWarnings({
    library(leaflet)
    library(sf)
    library(tidyverse)
    library(geojsonio)
    library(leaflet.extras)
    library(glue)
    library(crosstalk)
}))

## PRE-PROCESADO DE DATOS PARA LOS MAPAS
##==============================================

## Urls que se necesitan para los links
url_biota <- "https://www.biodiversidadcanarias.es/biota/especie/"
url_pne_info <- "https://descargas.grancanaria.com/jardincanario/ESPACIOS%20NATURALES%20PROTEGIDOS%20DE%20GRAN%20CANARIA/" 

## Función para crear un TSV con los datos de mis imágenes + los datos de BIOTA
f_species <- function(data){
    df_speices <- read_tsv(glue("data/species/processed/{data}")) |>
        mutate(family = str_to_title(family),
            order = str_to_title(order),
            class = str_to_title(class), 
            division = str_to_title(division),
            date = lubridate::dmy(gpsdatetime)) 

    return(df_speices)
}

## Trípticos informativos de Los ENPs que se implementarán en la capa de los ENPs
pne_info <- system("python3 code/python/02protected_natural_spaces_info.py | grep ^C-", intern = T)
df_pne_info <- data.frame(info = pne_info)
## Capa de los ENPs de la Isla de Gran Canaria a partir de los datos de IDECanarias
df_pne_processed <- df_pne_info |> 
  mutate(codigo = str_remove(info, "%.*"),
         codigo = str_replace(codigo, "^C-(\\d)$", "C-0\\1"))

enp_map <- read_sf("data/gran_canaria_shp/gc_pne.shp") %>% 
  st_transform(map, crs = 4326) %>%
  mutate(categoria = factor(categoria,
                            levels = c("Monumento Natural", 
                                       "Paisaje Protegido",
                                       "Parque Natural", 
                                       "Parque Rural", 
                                       "Reserva Natural Especial",
                                       "Reserva Natural Integral", 
                                       "Sitio de Interés Científico",
                                       "Parque Nacional"))) %>% 
  left_join(., df_pne_processed, by="codigo")  

## Crear una capa de especies Protegidas (flora)
protected_species <- read_sf("data/protected_species/protected_species_layer.shp") |>
  group_by(scientific, id_biota, geometry) |> 
  summarise(n = n()) |>  
  ungroup() |>
  group_by(geometry) |>
  summarise(species = paste0(glue("<i><a href='https://www.biodiversidadcanarias.es/biota/especie/{id_biota}'>{scientific}</i></a>"), collapse = "<br>> "),
            n = n())

## Crear una capa las zonas ZEC de Gran Canaria (IDECanarias)
zec_map <- read_sf("data/gran_canaria_shp/gc_zec.shp") |> 
  rename_all(tolower) |>
  st_transform(map, crs = 4326) |>
  mutate(Des_ZON = factor(des_zon,
                          levels = c("Zona de conservación prioritaria",
                                     "Zona de conservación",
                                     "Zona de restauración prioritaria",
                                     "Zona de restauración",
                                     "Zona de transición")))

## Delimitar el jardín botánico
jardin_botanico <- read_sf("data/gran_canaria_shp/jardin_botanico.shp")

## Definir los colores para los ENPs
pal_pne <- colorFactor(
  palette = c("#004078", "#80a0bd", "#f78000", "#e60000", "#00913f", "#034a31", "#BADBCA", "#fffb39"),
  domain = enp_map$categoria
)

## Definir los colores para las ZEC
pal_zec <- colorFactor(
  palette = c("#88c185", "#b4fcae", "#fedd86", "#feebb8", "#eaeaea"),
  domain = zec_map$des_zon
)

