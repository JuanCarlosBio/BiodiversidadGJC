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

species <- read_tsv("data/coord_species.tsv") %>%
    mutate(endemic_genus = case_when(endemic_genus == TRUE ~ "SI",
                                     endemic_genus == FALSE ~ "NO",
                                     is.na(endemic_genus) ~ "SIN IDENTIFICAR"),
           endemic_specie = case_when(endemic_specie == TRUE ~ "SI",
                                      endemic_specie == FALSE ~ "NO",
                                      is.na(endemic_specie) ~ "SIN IDENTIFICAR"),
           author = case_when(author == "NULL" ~ "",
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
                                       color = order,
                                       text = paste0("Filo: ", phylo,
                                                     "\nClase: ", class,
                                                     "\nOrden: ", order,
                                                     "\nFamilia: ", family,
                                                     "\nEspecie: ", specie, " ", author,
                                                     "\nEndémico (Género): ", endemic_genus,
                                                     "\nEndémico (Especie): ", endemic_specie,
                                                     "\t\nFecha y hora: ", gpsdatetime)),
                   size=4) +
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
            plot.background = element_rect(color = "#ffeed2", fill = "#ffeed2"),
            panel.background = element_rect(color="#cfe8fc", fill = "#cfe8fc")
        ) +
        labs(
            x = NULL, y = NULL,
            fill = NULL, color = NULL
        ) -> p

p1 <- ggplotly(p, tooltip = "text") %>%
    layout(showlegend=FALSE,
           width = 900,
           height = 500) %>% 
    config(scrollZoom = TRUE)
