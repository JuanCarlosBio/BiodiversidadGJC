#!/usr/bin/env Rscript

library(leaflet)
library(sf)
library(tidyverse)
library(geojsonio)
library(leaflet.extras)
library(glue)
library(crosstalk)

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

species <- read_tsv("data/coord_invertebrates.tsv",na ="") |>
    mutate(family = str_to_title(family),
           order = str_to_title(order),
           class = str_to_title(class), 
           phylo = str_to_title(phylo)) #|>
           #filter(category != "Especie protegida")

jardin_botanico <- read_sf("data/gran_canaria_shp/jardin_botanico.shp")

pal <- colorFactor(
  palette = c("#004078", "#80a0bd", 
              "#f78000", "#e60000", 
              "#00913f", "#034a31", 
              "#BADBCA"),
  domain = enp_map$categoria
)

pal_species <- colorFactor(
  palette = c("#ff0000", "#59ff00", 
              "#2600ff"),
  domain = species$category
)

pop_up <- paste0("ENP: ", enp_map$codigo, " ", enp_map$nombre, 
                "<br>", 
                "Categoría: ", enp_map$categoria)

pop_up_zec <- paste0("Código: ", zec_map$cod_zec, 
                     "<br>", 
                     "Nombre de la ZEC: ", zec_map$nom_zec) 

pop_up_species <- paste0(#glue("<img src='{species$sourcefile}'/>")
                         "=========================", 
                         "<br>Identificador (ID): ", species$id,
                         "<br>=========================",
                         "<br>Filo: ", species$phylo,
                         "<br>Clase: ", species$class,
                         "<br>Orden: ", species$order,
                         "<br>Familia: ", species$family,
                         "<br>Especie: ", species$specie, " ", species$author, # No funciona unfortunately
                         "<br>Nomb. Común: ", species$name, 
                         "<br>=========================",
                         "<br>Género Endémico: ", species$endemic_genus, 
                         "<br>Especie Endémica: ", species$endemic_specie,
                         "<br>Subespecie Endémica: ", species$endemic_subspecie,
                         "<br>Origen: ", species$origin, 
                         "<br>Categoría: ", species$category,
                         "<br>=========================",
                         "<br>Fecha: ", species$gpsdatetime,
                         "<br>=========================")

sd <- SharedData$new(data = species)

map <- leaflet() |>
  setView(-15.6, 27.95, zoom = 10) |>
  addTiles() |>
  addPolygons(data = enp_map, 
              fillColor = ~pal(categoria), 
              popup = pop_up, 
              weight = 0, fillOpacity = .5,
              group="ENP") |>
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
                   fillColor = ~pal_species(category), weight = .3, # fillColor = ~pal_species(class)  
                   radius = 8, group = "Especies") |>
  addLegend(data = species, "bottomleft", pal = pal_species,
            values = ~category, title = "<strong>Leyenda:</strong>", 
            opacity=1, group = "Leyenda") |>
  addLayersControl(baseGroups = c("SIN CAPA", "ENP", "ZEC"), 
                   overlayGroups = c("Especies", "Leyenda"),
                   options = layersControlOptions(collapsed = T)) |>
  addResetMapButton() |>
  htmlwidgets::onRender("
  function(el, x) {
    this.on('baselayerchange', function(e) {
      e.layer.bringToBack();
    });

      var css = '.info.legend.leaflet-control { text-align: left; }';
      var head = document.head || document.getElementsByTagName('head')[0];
      var style = document.createElement('style');
      style.type = 'text/css';
      if (style.styleSheet) {
        style.styleSheet.cssText = css;
      } else {
        style.appendChild(document.createTextNode(css));
      }
      head.appendChild(style);
  }
  ")
