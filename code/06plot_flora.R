#!/usr/bin/env Rscript

## El visor que planteo en el futuro
library(leaflet)
library(sf)
library(tidyverse)
library(geojsonio)
library(leaflet.extras)
library(glue)

set.seed(101997)

enp_map <- read_sf("data/gran_canaria_shp/gc_pne.shp") %>%
  st_transform(map, crs = 4326) %>%
  mutate(categoria = factor(categoria,
                            levels = c("Monumento Natural", 
                                       "Paisaje Protegido",
                                       "Parque Natural", 
                                       "Parque Rural", 
                                       "Reserva Natural Especial",
                                       "Reserva Natural Integral", 
                                       "Sitio de Interés Científico")))

zec_map <- sf::read_sf("data/gran_canaria_shp/gc_zec.shp") |> 
  dplyr::rename_all(tolower) |>
  sf::st_transform(map, crs = 4326) 

species <- read_tsv("data/coord_plantae.tsv") %>%
  mutate(family = str_to_title(family),
         order = str_to_title(order),
         class = str_to_title(class), 
         division = str_to_title(division))

jardin_botanico <- read_sf("data/gran_canaria_shp/jardin_botanico.shp")

pal <- colorFactor(
  palette = c("#004078", "#80a0bd", 
              "#f78000", "#e60000", 
              "#00913f", "#034a31", 
              "#BADBCA"),
  domain = enp_map$categoria
)

number_class <- length(unique(species$class))

pal_species <- colorFactor(
  palette = sample(colors(), number_class),
  domain = species$class
)


pop_up <- paste0("ENP: ", enp_map$codigo, " ", enp_map$nombre, 
                "<br>", 
                "Categoría: ", enp_map$categoria)

pop_up_zec <- paste0("Código: ", zec_map$cod_zec, 
                     "<br>", 
                     "Nombre de la ZEC: ", zec_map$nom_zec) 

pop_up_species <- paste0("=========================",  
                         "<br>Identificador (ID): ", species$id,
                         "<br>=========================",  
                         "<br>División: ", species$division,
                         "<br>Clase: ", species$class,
                         "<br>Orden: ", species$order,
                         "<br>Familia: ", species$family,
                         "<br>Especie: ", glue("{species$specie}"), " ", species$author,
                         "<br>Nomb. común: ", species$name,
                         "<br>=========================",
                         "<br>Género Endémico: ", species$endemic_genus, 
                         "<br>Especie Endémica: ", species$endemic_specie,
                         "<br>Subespecie Endémica: ", species$endemic_subspecie,
                         "<br>Origen: ", species$origin,
                         "<br>Categoría: ", species$category,
                         "<br>=========================",
                         "<br>Fecha y hora: ", species$gpsdatetime,
                         "<br>Latitud (GD) = ", as.character(round(species$latitude, 3)), 
                         "<br>Longitud (GD) = ", as.character(round(species$longitude, 3)),
                         "<br>=========================")

map <- leaflet() %>%
  setView(-15.6, 27.95, zoom = 9) %>%
  addTiles() %>%
  addPolygons(data = enp_map, 
              fillColor = ~pal(categoria), 
              popup = pop_up, 
              weight = 0, fillOpacity = .5,
              group = "ENP") %>%
  leaflet::addPolygons(data = zec_map,  
                       fillColor = "#4ce600",
                      popup = pop_up_zec, 
                      weight = 0, fillOpacity = .5,
                      group = "ZEC") %>%
  addPolygons(data = jardin_botanico, 
              fillColor = "yellow", fillOpacity = .5, weight = 1) %>%
  addCircleMarkers(data = species, 
                   lat = ~latitude, lng = ~longitude,
                   popup = pop_up_species, 
                   fillOpacity = 1, 
                   fillColor = ~pal_species(class), weight = .3,
                   radius = 7,
                   group = "Especies") |>
  leaflet::addLegend(data = species, "bottomleft", pal = pal_species,
                     values = ~class, title = "<strong>Leyenda: </strong>Clases", 
                     opacity=1, group = "Leyenda") %>%
  leaflet::addLayersControl(overlayGroups = c("ENP", "ZEC", "Leyenda", "Especies"),
                          options = leaflet::layersControlOptions(collapsed = T))  
  
  
