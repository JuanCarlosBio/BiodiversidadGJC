#!/usr/bin/env Rscript

## Se usarán los datos del procesados en 07process_map_layers.R 
source("code/R/07process_map_layers.R")

## URL donde pongo fotos para las etiquetas de las especies
url_photos_species <- "https://raw.githubusercontent.com/biologyphotos/volume1/refs/heads/main/"

## Cargamos las especies, en este caso de metazoos (organismos invertebrados)
species <- f_species("coord_invertebrates.tsv") |>
  ## Creamos un campo con las direcciones de las imágenes propias para las etiquetas
  mutate(species_photos = glue("{url_photos_species}{id_biota}.jpg"))

## Establecemos colores del mapa para las especies:
## * Especie Introducida = rojo
## * Especie Nativa = verde
## * Especie protegida = azul
pal_species <- colorFactor(
  palette = c("#ff0000", "#59ff00", "#2600ff"),
  domain = species$category
)

## Para poder filtrar las especies, tenemos que crear un objeto SharedData,
## Al que llamaremos "sd"
sd <- SharedData$new(data = species)

## Mapa del Leaflet para las especies de invertebrados
map <- leaflet() |>
  setView(-15.6, 27.95, zoom = 10) |>
  #addTiles() |>
  addProviderTiles(
    providers$Esri.WorldImagery,
    options = providerTileOptions(minZoom = 10)
  ) |>
  addProviderTiles(
    providers$CartoDB.VoyagerOnlyLabels,
    options = providerTileOptions(minZoom = 10)    
  ) |>
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
              popup =  paste0("<strong>ENP</strong>: ", 
                              enp_map$codigo, " ", 
                              glue("<u>{enp_map$nombre}</u>"), 
                              "<br>", 
                              "<strong>Categoría</strong>: ", 
                              enp_map$categoria,
                              glue("<br><a href={url_pne_info}{enp_map$info}>Información del espacio</a>")  
  ) |> 
                lapply(htmltools::HTML),
              popupOptions = labelOptions(
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
                   popup = paste0("<p style='text-align:left;'>", 
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
                   label = paste0(glue("<i>{species$specie}</i>"),
                                 glue("<br>---------------------------------------------------------------------"),
                                 glue("<br><img class='center' src='{species$species_photos}' style='width: 270px; height: 200px;'>")) |> lapply(htmltools::HTML), 
                   labelOptions = labelOptions(textsize = 11),
                   fillOpacity = 1, 
                   fillColor = ~pal_species(category), weight = .3, # fillColor = ~pal_species(class)  
                   radius = 8, group = "Especies") |>
  addLegend(data = species, "bottomright", pal = pal_species,
            values = ~category, title = "<strong>Leyenda:</strong>", 
            opacity=1, group = "Leyenda") |>
  addLayersControl(baseGroups = c("SIN CAPA", 
                                  "Espacios Naturales<br>Protegidos", 
                                  "Red Natura 2000" 
                                  ), 
                   overlayGroups = c("Especies", "Leyenda"),
                   options = layersControlOptions(collapsed = T)) |>
  addResetMapButton() |>
  addScaleBar("bottomleft", scaleBarOptions(metric = TRUE, imperial = FALSE)) |>
  ## La primera función de JS lo que hace es asegurar que los puntos de las especies se encuentren siempre al frente,
  ## mientras que el resto de capas se encuentren en segundo plano. La segunda parte de css, lo que hace es que el texto
  ## de la leyenda se encuentre justificado hacia la derecha
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
