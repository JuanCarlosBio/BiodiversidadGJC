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

species <- read_tsv("data/coord_plantae.tsv") %>%
    mutate(author = case_when(author == "NULL" ~ "",
                              author != "NULL" ~ as.character(author)),
           family = str_to_title(family),
           order = str_to_title(order),
           class = str_to_title(class), 
           division = str_to_title(division),
           subdivision = str_to_title(subdivision))

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
        geom_point(data = species, aes(longitude, 
                                       latitude, 
                                       color = class,
                                       text = paste0("=========================",  
                                                     "\nIdentificador (ID): ", id,
                                                     "\n=========================",  
                                                     "\nDivisión: ", division,
                                                     "\nSubdivision: ", subdivision,
                                                     "\nClase: ", class,
                                                     "\nOrden: ", order,
                                                     "\nFamilia: ", family,
                                                     "\nEspecie: ", specie, " ", author,
                                                     "\nNomb. común: ", name,
                                                     "\n=========================",
                                                     "\nGénero Endémico: ", endemic_genus, ", Especie Endémica: ", endemic_specie,
                                                     "\nOrigen: ", origin,
                                                     "\nCategoría: ", category,
                                                     "\n=========================",
                                                     "\nFecha y hora: ", gpsdatetime,
                                                     "\nLat = ", sprintf("%.3f", latitude), 
                                                     ", Lon = ", sprintf("%.3f", longitude),
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
            panel.background = element_rect(color="#cfe8fc", fill = "#cfe8fc")
        ) +
        labs(
            x = NULL, y = NULL,
            fill = NULL, color = NULL
        ) -> flora_plot

flora_plotly <- ggplotly(flora_plot, tooltip = "text") %>%
    layout(showlegend=T,
           width = 900,
           height = 500) %>% 
    config(scrollZoom = TRUE)

## credit to stack overflow page to solve legend ggplot bug:
## https://stackoverflow.com/questions/49133395/strange-formatting-of-legend-in-ggplotly-in-r
for (i in 1:length(flora_plotly$x$data)){
  if (!is.null(flora_plotly$x$data[[i]]$name)){
    flora_plotly$x$data[[i]]$name =  gsub("\\(","",str_split(flora_plotly$x$data[[i]]$name,",")[[1]][1])
  }
}
