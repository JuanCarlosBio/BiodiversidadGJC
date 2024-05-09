#!/usr/bin/env Rscript

## El visor que planteo en el futuro
library(leaflet)
library(sf)
library(tidyverse)
library(geojsonio)
library(leaflet.extras)
library(glue)

seed <- 97

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

species <- read_tsv("data/coord_invertebrates.tsv",na ="") %>%
    mutate(family = str_to_title(family),
           order = str_to_title(order),
           class = str_to_title(class), 
           phylo = str_to_title(phylo))

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

jardin_botanico <- read_sf("data/gran_canaria_shp/jardin_botanico.shp")

pop_up <- paste0("ENP: ", enp_map$codigo, " ", enp_map$nombre, 
                "<br>", 
                "Categoría: ", enp_map$categoria)


pop_up_species <- paste0("=========================", 
                         "<br>Identificador (ID): ", species$id,
                         "<br>=========================",
                         "<br>Filo: ", species$phylo,
                         "<br>Clase: ", species$class,
                         "<br>Orden: ", species$order,
                         "<br>Familia: ", species$family,
                         "<br>Especie: ", species$specie, " ", species$author,
                         "<br>Nomb. Común: ", species$name, 
                         "<br>=========================",
                         "<br>Género Endémico: ", species$endemic_genus, 
                         "<br>Especie Endémica: ", species$endemic_specie,
                         "<br>Subespecie Endémica: ", species$endemic_subspecie,
                         "<br>Origen: ", species$origin, 
                         "<br>Categoría: ", species$category,
                         "<br>=========================",
                         "<br>Fecha y hora: ", species$gpsdatetime,
                         "<br>Lat = ", sprintf("%.3f", species$latitude, 3), 
                         ", Lon = ", sprintf("%.3f", species$longitude, 3),
                         "<br>=========================")

map <- leaflet() %>%
  setView(-15.6, 27.95, zoom = 9) %>%
  addTiles() %>%
  addPolygons(data = enp_map, 
              fillColor = ~pal(categoria), 
              popup = pop_up, 
              weight = 0, fillOpacity = .5) %>%
  addPolygons(data = jardin_botanico, 
              fillColor = "yellow", fillOpacity = .5, weight = 1) %>%
  addCircleMarkers(data = species, 
                   lat = ~latitude, lng = ~longitude,
                   popup = pop_up_species, 
                   fillOpacity = 1, 
                   fillColor = ~pal_species(class), weight = .3) 
