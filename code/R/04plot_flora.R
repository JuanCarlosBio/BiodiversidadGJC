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
# Url for finding the species in biota https://www.biodiversidadcanarias.es/biota/
url_biota <- "https://www.biodiversidadcanarias.es/biota/especie/"

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

species <- read_tsv("data/coord_plantae.tsv") |>
  mutate(family = str_to_title(family),
         order = str_to_title(order),
         class = str_to_title(class), 
         division = str_to_title(division)) |>
         filter(category != "Especie protegida")

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
  addPolygons(
    data = enp_map, 
    fillColor = ~pal_pne(categoria), 
    color = "transparent",
    weight = 0, fillOpacity = .5,
    dashArray = "3",
    highlightOptions = highlightOptions(weight = 5, 
                                        color = "#666", 
                                        fillOpacity = .7,
                                        dashArray = "", 
                                        bringToFront = FALSE),
    label =  paste0(
      "<strong>ENP</strong>: ", 
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
  addPolygons(data = hic_map, 
              fillColor = ~pal_hic(habue4dva1), 
              color = "transparent",
              weight = 0, fillOpacity = .5,
              dashArray = "3",
              popup = paste0(
                "<strong>Código HIC:</strong>): ", glue("<u>{hic_map$habue4dva1}</u>"),
                "<br><strong>Nombre:</strong> ", hic_map$name
                ) |> lapply(htmltools::HTML),  
              highlightOptions = highlightOptions(weight = 5,
                                                  color = "#666",
                                                  fillOpacity = .7,
                                                  dashArray = "",
                                                  bringToFront = FALSE),
              group = "Hábitats de Interés<br>Comunitarios") |>
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
              highlightOptions = highlightOptions(weight = 5,
                                                  color = "#666",
                                                  fillOpacity = .7,
                                                  dashArray = "",
                                                  bringToFront = FALSE),
              weight = 0, fillOpacity = .9,
              group = "Especies Protegidas") |>
  addPolygons(data = jardin_botanico, 
              fillColor = "yellow", fillOpacity = .5, weight = 1) |>
  addCircleMarkers(data = sd, 
                   lat = ~latitude, lng = ~longitude,
                   popup = paste0(#glue("<img src='{species$sourcefile}'/>"),
                                  "<p style='text-align:left;'>", 
                                  "<strong>Identificador (ID):</strong> ", species$id,
                                  glue("<br><a href={url_biota}{species$id_biota}><strong>Biota:</strong> {species$id_biota}</a>"), 
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
                                  "Red Natura 2000", "Hábitats de Interés<br>Comunitarios", 
                                  "Especies Protegidas"), 
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

