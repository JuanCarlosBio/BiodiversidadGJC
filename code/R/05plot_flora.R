#!/usr/bin/env Rscript

## CARGAR Y PROCESAR DATOS
##==============================================

## Se usarán los datos del procesados en 07process_map_layers.R 
source("code/R/07process_map_layers.R")

## URL donde pongo fotos para las etiquetas de las especies
url_photos_species <- "https://raw.githubusercontent.com/biologyphotos/flora_gc/refs/heads/main/"

## Cargamos las especies, en este caso de metazoos (organismos invertebrados)
species <- f_species("coord_plantae.tsv") |>
  filter(category != "Especie protegida") |>
  mutate(species_photos = glue("{url_photos_species}{id_biota}.jpg"))

## Creamos un recuento de especies en los ENP y lo añadiremos a la etiqueta
system("python3 code/python/03_count_pne_species.py")
species_pne <- read_csv("data/species/pne_species_count.csv")
protected_species_pne <- read_csv("data/protected_species/temp_protected_species.csv")
all_species_pne <- rbind(species_pne, protected_species_pne)

## Capa de las especies protegidas de flora, formada por las especies y número de estas
enp_map <- enp_map |> 
  left_join(all_species_pne, by = "codigo") |>
  mutate(category = str_replace_all(tolower(category), pattern = " ", replacement = "_")) |>
  pivot_wider(
    names_from = "category", 
    values_from = n,
    values_fn = sum
  ) |> 
  select(-"NA") |>   
  mutate(across(where(is.numeric), ~replace_na(., 0)),
         total_species = especie_nativa + especie_protegida + especie_introducida + especie_traslocada)


## Establecemos colores para las especies:
## * Especie Introducida = rojo
## * Especie Nativa = verde
## * Especie traslocada = naranja
pal_species <- colorFactor(
  palette = c("#ff0000", "#59ff00", "#ffae00"),
  domain = species$category
)

## La capa de especies protegidas se colorearás según el siguente intervalo:
bins <- c(1, 2, 4, 6, Inf)
pal_protected_especies <- colorBin("YlOrRd", domain = protected_species$n, bins = bins)

## Para poder filtrar las especies, tenemos que crear un objeto SharedData,
## Al que llamaremos "sd"
sd <- SharedData$new(data = species)

## FIN DE CARGAR Y PROCESAR DATOS
##==============================================

## MAPA INTERACTIVO DE LEAFLET
##==============================================
map <- leaflet() |>
  setView(-15.6, 27.95, zoom = 10) |>
#  addTiles() |>
  addProviderTiles(
    providers$Esri.WorldImagery,
    options = providerTileOptions(minZoom = 10) 
  ) |>
  addProviderTiles(
    providers$CartoDB.VoyagerOnlyLabels,
    options = providerTileOptions(minZoom = 10)   
  ) |>
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
    popup =  paste0(
      "<strong>ENP</strong>: ", 
      enp_map$codigo, " ", 
      glue("<u>{enp_map$nombre}</u>"), 
      "<br>", 
      "<strong>Categoría</strong>: ", 
      enp_map$categoria,
      glue("<br><a href={url_pne_info}{enp_map$info}>Información del espacio</a>"),
      "<hr style=border: 1px solid black; width: 100%>",
      "<strong><u>Nº de especies observadas en el ENP:</u></strong>",
      glue("<br><strong><span style='color: #15d600'>Nativas</span></strong> = {enp_map$especie_nativa}, <strong><span style='color: blue'>Protegidas</span></strong> = {enp_map$especie_protegida}"), 
      glue("<br><strong><span style='color: #ff0000'>Introducidas</span></strong> = {enp_map$especie_introducida}, <strong><span style='color: #ffae00'>Traslocadas<span></strong> = {enp_map$especie_traslocada}"),
      glue("<br><strong>Total de especies observadas</strong> = <u>{enp_map$total_species}</u>")
      ) |> 
        lapply(htmltools::HTML),
    popupOptions = labelOptions(
      style = list("font-weight" = "normal",
                   padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"
    ),
    group = "Espacios Naturales Protegidos") |>
  addPolygons(data = zec_map,  
              fillColor = ~pal_zec(des_zon),
              color = "transparent",
              dashArray = "3",
              highlightOptions = highlightOptions(weight = 5,
                                                  color = "#666",
                                                  fillOpacity = .7,
                                                  dashArray = "",
                                                  bringToFront = FALSE),              
              label = paste0("<p align='left'>",
                             "<strong>Código:</strong> ", zec_map$cod_zec, 
                             glue("<br><strong>Nombre de la ZEC:</strong> <u>{zec_map$nom_zec}</u>"),
                             glue("<br><strong>Zonificación:</strong> <u>{zec_map$des_zon}</u> ({zec_map$tip_zon})"),
                             "</p>") |> 
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
              popup = paste0("<p style='text-align:left;'>",
                             "<strong>ESPECIES PROTEGIUDAS DEL LUGAR</strong>", 
                             "<hr style=border: 1px solid black; width: 100%>", 
                             glue("🌱️ <strong>Número de especies protegidas en total: <u>{protected_species$n}</u></strong>"),
                             glue("<br>> {protected_species$species}"),
                             "</p>") |> 
                lapply(htmltools::HTML),
              popupOptions = labelOptions(
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
                   popup = paste0(
                    #glue("<img src='{species$sourcefile}'/>"),
                    "<p style='text-align:left;'>", 
                    "<strong>Identificador (ID):</strong> ", species$id,
                    glue("<br><a href={url_biota}{species$id_biota}><strong>Biota:</strong> {species$id_biota}</a>"), 
                    "<br>-----<br>",  
                    "<strong>División:</strong> ", species$division,
                    "<br><strong>Clase:</strong> ", species$class,
                    "<br><strong>Orden:</strong> ", species$order,
                    "<br><strong>Familia:</strong> ", species$family,
                    "<br><strong>Especie:</strong> ", glue("<i>{species$scientific_name}</i>"),
                    "<br><strong>Nomb. común:</strong> ", species$name,
                    "<br>-----<br>",
                    "<strong>Género Endémico</strong>: ", species$endemic_genus, 
                    "<br><strong>Especie Endémica:</strong> ", species$endemic_specie,
                    "<br><strong>Subespecie Endémica:</strong> ", species$endemic_subspecie,
                    "<br><strong>Origen:</strong> ", species$origin,
                    "<br>-----<br>",
                    "<strong>Fecha:</strong> ", species$gpsdatetime,
                    "</p>"
                  ) |> lapply(htmltools::HTML), 
                   label = paste0(
                    "<strong>Especie</strong>",
                    glue("<br><i>{species$scientific_name}</i>"),
                    glue("<br><i>{species$name}</i>"),
                    glue("<br>---------------------------------------------------------------------"),
                    glue("<br><img class='center' src='{species$species_photos}' style='width: 270px; height: 200px;'>")
                  ) |> lapply(htmltools::HTML), 
                   labelOptions = labelOptions(textsize = 11),
                   fillOpacity = 1, 
                   fillColor = ~pal_species(category), weight = .3, # fillColor = ~pal_species(class)  
                   radius = 8,
                   group = "Especies") |>
  addLegend(data = protected_species, 
            "bottomright", 
            pal = pal_protected_especies,
            values = ~n, 
            title = "<strong>Especies protegidas</strong>", 
            opacity=1, 
            group = "Leyenda especies protegidas") |>
  addLegend(data = species, "bottomright", pal = pal_species,
            values = ~category, title = "<strong>Especies NO protegidas</strong>", 
            opacity=1, group = "Leyenda Especies") |> 
  addLayersControl(baseGroups = c("SIN CAPA", 
                                  "Espacios Naturales Protegidos", 
                                  "Red Natura 2000", 
                                  "Especies Protegidas"), 
                   overlayGroups = c("Especies", "Leyenda Especies", 
                                     "Leyenda especies protegidas"),
                   options = layersControlOptions(collapsed = T, autoZIndex = TRUE))  |>
  addResetMapButton() |>
  addScaleBar("bottomleft", scaleBarOptions(metric = TRUE, imperial = FALSE)) |>
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

