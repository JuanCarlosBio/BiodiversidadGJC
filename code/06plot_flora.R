#!/usr/bin/env Rscript

## Load the libraries
library(leaflet)
library(sf)
library(tidyverse)
library(geojsonio)
library(leaflet.extras)
library(glue)
library(crosstalk)

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

protected_species <- read_sf("data/gran_canaria_shp/protected_species_layer.shp") |>
  mutate(specie = paste0(specie, " ", "(", str_to_lower(name), ")")) |>
  group_by(specie, geometry) |>
  summarise(n = n()) |>
  ungroup() |>
  group_by(geometry) |>
  summarise(species = paste(specie, collapse = "<br>> "),
            n = n())

zec_map <- read_sf("data/gran_canaria_shp/gc_zec.shp") |> 
  rename_all(tolower) |>
  st_transform(map, crs = 4326) 

species <- read_tsv("data/coord_plantae.tsv") |>
  mutate(family = str_to_title(family),
         order = str_to_title(order),
         class = str_to_title(class), 
         division = str_to_title(division)) |>
         filter(category != "Especie protegida")

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
  palette = c("#ff0000", "#59ff00", "#ffae00"),
  domain = species$category
)

bins <- c(1, 2, 4, Inf)
pal_protected_especies <- colorBin("YlOrRd", domain = protected_species$n, bins = bins)

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
  addPolygons(data = protected_species,
              fillColor = ~pal_protected_especies(n),
              color = "transparent",
              dashArray = "3",
              label = paste0("<p style='text-align:left;'>",
                             "###=================================###",
                             "<br>### <strong>ESPECIES PROTEGIUDAS DEL LUGAR</strong> ###", 
                             "<br>###=================================###", 
                             glue("<br>==> <strong>Número de especies protegidas en total: <u>{protected_species$n}</u></strong>"),
                             glue("<br>> <i>{protected_species$species}</i>"),
                             "</p>") |> 
                lapply(htmltools::HTML),
              labelOptions = labelOptions(
                style = list("font-weight" = "normal",
                             padding = "3px 8px"),
                textsize = "10px",
                direction = "auto"
              ),              
              weight = 0, fillOpacity = .9,
              group = "Especies Protegidas") |>
  addPolygons(data = jardin_botanico, 
              fillColor = "yellow", fillOpacity = .5, weight = 1) |>
  addCircleMarkers(data = sd, 
                   lat = ~latitude, lng = ~longitude,
                   popup = paste0(#glue("<img src='{species$sourcefile}'/>"),
                                  "<p style='text-align:left;'", 
                                  "=========================",  
                                  "<br><strong>Identificador (ID</strong>): ", species$id,
                                  "<br>=========================",  
                                  "<br><strong>División:</strong> ", species$division,
                                  "<br><strong>Clase:</strong> ", species$class,
                                  "<br><strong>Orden:</strong> ", species$order,
                                  "<br><strong>Familia:</strong> ", species$family,
                                  "<br><strong>Especie:</strong> ", glue("<i>{species$specie}</i>"), " ", species$author,
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
                   radius = 8,
                   group = "Especies") |>
  addLegend(data = protected_species, 
            "bottomleft", 
            pal = pal_protected_especies,
            values = ~n, 
            title = "<strong>Especies protegidas</strong>", 
            opacity=1, 
            group = "Leyenda especies<br>protegidas") |>
  addLegend(data = species, "bottomleft", pal = pal_species,
            values = ~category, title = "<strong>Especies NO protegidas</strong>", 
            opacity=1, group = "Leyenda Especies") |> 
  addLayersControl(baseGroups = c("SIN CAPA", "Espacios Naturales<br>Protegidos", 
                                  "Red Natura 2000", "Especies Protegidas"), 
                   overlayGroups = c("Especies", "Leyenda Especies", 
                                     "Leyenda especies<br>protegidas"),
                   options = layersControlOptions(collapsed = T, autoZIndex = TRUE))  |>
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

