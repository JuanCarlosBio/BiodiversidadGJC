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

species <- read_tsv("data/coord_invertebrates.tsv") %>%
    mutate(author = case_when(author == "NULL" ~ "",
                              author != "NULL" ~ as.character(author)),
           family = str_to_title(family),
           order = str_to_title(order),
           class = str_to_title(class), 
           phylo = str_to_title(phylo))

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
                                       text = paste0("Filo: ", phylo,
                                                     "\nClase: ", class,
                                                     "\nOrden: ", order,
                                                     "\nFamilia: ", family,
                                                     "\nEspecie: ", specie, " ", author,
                                                     "\nGénero Endémico: ", endemic_genus, "/ Especie Endémica: ", endemic_specie,
                                                     "\nFecha y hora: ", gpsdatetime,
                                                     "\nLatitud: ", latitude, 
                                                     "\nLongitud", longitude)),
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
        labs(
            x = NULL, y = NULL,
            fill = NULL, color = NULL
        ) -> invertebrates_plot

invertebrates_plotly <- ggplotly(invertebrates_plot, tooltip = "text") %>%
    layout(showlegend=T,
           width = 900,
           height = 500) %>% 
    config(scrollZoom = TRUE)
