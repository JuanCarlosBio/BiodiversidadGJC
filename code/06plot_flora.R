#!/usr/bin/env Rscript

library(leaflet)
library(sf)
library(tidyverse)
library(geojsonio)
library(leaflet.extras)
library(glue)
library(crosstalk)

set.seed(1234)

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

zec_map <- read_sf("data/gran_canaria_shp/gc_zec.shp") |> 
  rename_all(tolower) |>
  st_transform(map, crs = 4326) 

species <- read_tsv("data/coord_plantae.tsv") |>
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
                         "<br>=========================")

sd <- SharedData$new(data = species)

map <- leaflet() |>
  setView(-15.6, 27.95, zoom = 10) |>
  addTiles() |>
  addPolygons(data = enp_map, 
              fillColor = ~pal(categoria), 
              popup = pop_up, 
              weight = 0, fillOpacity = .5,
              group = "ENP") |>
  addPolygons(data = zec_map,  
               fillColor = "#4ce600",
              popup = pop_up_zec, 
              weight = 0, fillOpacity = .5,
              group = "ZEC") |>
  addPolygons(data = jardin_botanico, 
              fillColor = "yellow", fillOpacity = .5, weight = 1) |>
  addCircleMarkers(data = sd, 
                   lat = ~latitude, lng = ~longitude,
                   popup = pop_up_species, 
                   fillOpacity = 1, 
                   fillColor = "#3fff00", weight = .3, # fillColor = ~pal_species(class)  
                   radius = 8,
                   group = "Especies") |>
#  addLegend(data = species, "bottomleft", pal = pal_species,
#            values = ~class, title = "<strong>Leyenda: </strong>Clases", 
#            opacity=1, group = "Leyenda") |>
  addLayersControl(baseGroups = c("SIN CAPA", "ENP", "ZEC"), 
                   overlayGroups = c("Leyenda", "Especies"),
                   options = layersControlOptions(collapsed = T, autoZIndex = TRUE))  |>
  addResetMapButton() |>
  htmlwidgets::onRender("
    function(el, x) {
      this.on('baselayerchange', function(e) {
        e.layer.bringToBack();
      })
    }
  ") 

