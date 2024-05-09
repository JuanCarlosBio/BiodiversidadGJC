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

species <- read_tsv("data/coord_plantae.tsv") %>%
  mutate(family = str_to_title(family),
         order = str_to_title(order),
         class = str_to_title(class), 
         division = str_to_title(division))

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
                         "<br>Lat = ", sprintf("%.3f", species$latitude), 
                         ", Lon = ", sprintf("%.3f", species$longitude),
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
  
library(tidyverse)
library(glue)
library(sf)
library(plotly)

map <- read_sf("data/gran_canaria_shp/gc_muni.shp") %>%
    st_transform(map, crs = 4326) 

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

enp_map2 <- enp_map %>%
    filter(codigo %in% c("C-14", "C-15", "C-20", "C-21"))

species <- read_tsv("data/coord_invertebrates.tsv",na ="") %>%
    mutate(family = str_to_title(family),
           order = str_to_title(order),
           class = str_to_title(class), 
           phylo = str_to_title(phylo))

species[is.na(species)] <- "-"  

jardin_botanico <- read_sf("data/gran_canaria_shp/jardin_botanico.shp") 

species %>%
    ggplot() +
        geom_sf(data = map, fill = "#edd393") +
        geom_sf(data = enp_map, aes(fill = categoria,  
                                    text = paste0("\nENP: ", codigo, " ", nombre,
                                                  "\nCategoría del ENP: ", categoria)),
                alpha = .75) +
        geom_sf(data = enp_map2, aes(fill = categoria,  
                                    text = paste0("\nENP: ", codigo, " ", nombre,
                                                  "\nCategoría del ENP: ", categoria)),

        alpha = .75) +
        geom_sf_text(data = enp_map, aes(label = "", 
                            fill = categoria,
                            text = paste0("\nENP: ", codigo, " ", nombre,
                                          "\nCategoría del ENP: ", categoria)),
        alpha = 0) +
        geom_sf(data = jardin_botanico, fill = "yellow", aes(text = Name)) +
        geom_point(data = species, aes(longitude, 
                                       latitude, 
                                       color = class,
                                       text = paste0("=========================", 
                                                     "\nIdentificador (ID): ", id,
                                                     "\n=========================",
                                                     "\nFilo: ", phylo,
                                                     "\nClase: ", class,
                                                     "\nOrden: ", order,
                                                     "\nFamilia: ", family,
                                                     "\nEspecie: ", specie, " ", author,
                                                     "\nNomb. Común: ", name, 
                                                     "\n=========================",
                                                     "\nGénero Endémico: ", endemic_genus, 
                                                     "\nEspecie Endémica: ", endemic_specie,
                                                     "\nSubespecie Endémica: ", endemic_subspecie,
                                                     "\nOrigen: ", origin, 
                                                     "\nCategoría: ", category,
                                                     "\n=========================",
                                                     "\nFecha y hora: ", gpsdatetime,
                                                     "\nLat = ", sprintf("%.3f", latitude, 3), 
                                                     ", Lon = ", sprintf("%.3f", longitude, 3),
                                                     "\n=========================")),
                   size=3) +
        coord_sf() +
        scale_fill_manual(
            breaks = c("Monumento Natural", 
                       "Paisaje Protegido",
                       "Parque Natural", 
                       "Parque Rural", 
                       "Reserva Natural Especial",
                       "Reserva Natural Integral", 
                       "Sitio de Interés Científico"),
            values = c("#004078", "#80a0bd", 
                       "#f78000", "#e60000", 
                       "#00913f", "#034a31", 
                       "#BADBCA")) +
        theme_test() +
        theme(
            plot.background = element_rect(color = "#fff3d8", fill = "#fff3d8"),
            panel.background = element_rect(color="#cfe8fc", fill = "#cfe8fc"),
            legend.background = element_rect(color = "black")
        ) +
        #guides(color = FALSE) +
        labs(
            x = NULL, y = NULL,
            fill = NULL, color = NULL
        ) -> invertebrates_plot

invertebrates_plotly <- ggplotly(invertebrates_plot, tooltip = "text") %>%
    layout(showlegend=T,
           width = 900,
           height = 500) %>% 
    style(trace = 0, traces = 1, legendgroup = 'Species', name = 'Species') %>%
    config(scrollZoom = TRUE)

## credit to stack overflow page to solve legend ggplot bug:
## https://stackoverflow.com/questions/49133395/strange-formatting-of-legend-in-ggplotly-in-r
for (i in 1:length(invertebrates_plotly$x$data)){
  if (!is.null(invertebrates_plotly$x$data[[i]]$name)){
    invertebrates_plotly$x$data[[i]]$name =  gsub("\\(","",str_split(invertebrates_plotly$x$data[[i]]$name,",")[[1]][1])
  }
} 