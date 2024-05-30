#!/usr/bin/env Rscript

## Load the libraries
library(leaflet)
library(sf)
library(tidyverse)
library(geojsonio)
library(leaflet.extras)
library(glue)
library(crosstalk)

# Url for finding the species in biota https://www.biodiversidadcanarias.es/biota/
url_biota <- "https://www.biodiversidadcanarias.es/biota/especie/"

## Load the data
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
           phylo = str_to_title(phylo)) 

jardin_botanico <- read_sf("data/gran_canaria_shp/jardin_botanico.shp")

## Create the color palettes for the layers
pal_pne <- colorFactor(
  palette = c("#004078", "#80a0bd", 
              "#f78000", "#e60000", 
              "#00913f", "#034a31", 
              "#BADBCA"),
  domain = enp_map$categoria
)

pal_species <- colorFactor(
  palette = c("#ff0000", "#59ff00", "#2600ff"),
  domain = species$category
)

sd <- SharedData$new(data = species)

map <- leaflet() |>
  setView(-15.6, 27.95, zoom = 10) |>
  addTiles() |>
  addPolygons(data = enp_map, 
              fillColor = ~pal_pne(categoria), 
              color = "transparent",
              weight = 0, fillOpacity = .5,
              dashArray = "3",
              highlightOptions = highlightOptions(weight = 5,
                                                  color = "#666",
                                                  fillOpacity = .7,
                                                  dashArray = "",
                                                  bringToFront = FALSE),
              label =  paste0("<strong>ENP</strong>: ", 
                              enp_map$codigo, " ", 
                              glue("<u>{enp_map$nombre}</u>"), 
                              "<br>", 
                              "<strong>Categoría</strong>: ", 
                              enp_map$categoria) |> 
                lapply(htmltools::HTML),
              labelOptions = labelOptions(
                style = list("font-weight" = "normal",
                             padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"
              ),
              group = "Espacios Naturales<br>Protegidos") |>
  addPolygons(data = zec_map,  
              fillColor = "#4ce600",
              color = "transparent",
              dashArray = "3",
              highlightOptions = highlightOptions(weight = 5,
                                                  color = "#666",
                                                  fillOpacity = .7,
                                                  dashArray = "",
                                                  bringToFront = FALSE),              
              label = paste0("<strong>Código:</strong> ", zec_map$cod_zec, 
                             "<br>", 
                             "<strong>Nombre de la ZEC:</strong> ", 
                             glue("<u>{zec_map$nom_zec}</u>")) |> 
                lapply(htmltools::HTML),
              labelOptions = labelOptions(
                style = list("font-weight" = "normal",
                             padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"
              ),              
              weight = 0, fillOpacity = .5,
              group = "Red Natura 2000") |>
  addPolygons(data = jardin_botanico, 
              fillColor = "yellow", fillOpacity = .5, weight = 1) |>
  addCircleMarkers(data = sd, 
                   lat = ~latitude, lng = ~longitude,
                   popup = paste0(#glue("<img src='{species$sourcefile}'/>")
                                  "<p style='text-align:left;'>", 
                                  "<strong>Identificador (ID</strong>): ", species$id,
                                  glue("<br><a href={url_biota}{species$id_biota}><strong>Biota:</strong> {species$id_biota}</a>"),
                                  "<br>=========================",
                                  "<br><strong>Filo:</strong> ", species$phylo,
                                  "<br><strong>Clase:</strong> ", species$class,
                                  "<br><strong>Orden:</strong> ", species$order,
                                  "<br><strong>Familia:</strong> ", species$family,
                                  "<br><strong>Especie:</strong> ", glue("<i>{species$specie}</i>"), " ", species$author, # No funciona unfortunately
                                  "<br><strong>Nomb. común:</strong> ", species$name, 
                                  "<br>=========================",
                                  "<br><strong>Género Endémico</strong>: ", species$endemic_genus, 
                                  "<br><strong>Especie Endémica:</strong> ", species$endemic_specie,
                                  "<br><strong>Subespecie Endémica:</strong> ", species$endemic_subspecie,
                                  "<br><strong>Origen:</strong> ", species$origin, 
                                  "<br>=========================",
                                  "<br><strong>Fecha:</strong> ", species$gpsdatetime,
                                  "<br>=========================",
                                  "</p>") |> lapply(htmltools::HTML), 
                   fillOpacity = 1, 
                   fillColor = ~pal_species(category), weight = .3, # fillColor = ~pal_species(class)  
                   radius = 8, group = "Especies") |>
  addLegend(data = species, "bottomleft", pal = pal_species,
            values = ~category, title = "<strong>Leyenda:</strong>", 
            opacity=1, group = "Leyenda") |>
  addLayersControl(baseGroups = c("SIN CAPA", "Espacios Naturales<br>Protegidos", "Red Natura 2000"), 
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
