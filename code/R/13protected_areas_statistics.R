
library(tidyverse)
library(gt)
library(ggtext)
library(cowplot)
library(glue)
library(sf)

species_db <- read_csv("data/species/processed/species_data_base.csv")
eennpp <- st_read("data/gran_canaria_shp/gc_pne.shp") 
municipios <- st_read("data/gran_canaria_shp/gc_muni.shp")
zec <- st_read("data/gran_canaria_shp/gc_zec.shp")

## How many species per islands do I have?

## Pictures

n_pictures <- species_db |>
  group_by(isla_muni) |>
  summarise(n = n()) |>
  ungroup() |>
  arrange(desc(n))

## Species
species_per_islands <- species_db |>
  select(scientific_name, isla_muni) |>
  distinct() |>
  group_by(isla_muni) |>
  summarise(n = n()) |>
  ungroup() |>
  arrange(desc(n))

## Species metazoa or plantae
species_per_islands_type <- species_db |>
  select(scientific_name, isla_muni, domain) |>
  distinct() |>
  group_by(isla_muni, domain) |>
  summarise(n = n()) |>
  ungroup() |>
  arrange(desc(n))

y_species_per_islands_axis <- max(species_per_islands$n) + (max(species_per_islands$n) * 0.2)

plot_species_per_islands <- species_per_islands |>
  ggplot(aes(reorder(isla_muni, n), n, fill = isla_muni)) +
  geom_col(color = "black", size = 2,width = .3, show.legend = FALSE) +
  geom_text(aes(isla_muni, n, label = n),
            position = "identity",
            color = "black", 
            fontface = "bold",
            size=7, 
            show.legend = FALSE,
            vjust = -.5) +
  scale_y_continuous(expand = expansion(0),
                     limits = c(0, y_species_per_islands_axis)) +
  labs(
    title = "Número de especies por isla",
    y = "Número de especies",
    x = "Isla de procedencia"
  ) +
  scale_fill_manual(
    breaks = c("TENERIFE", "GRAN CANARIA", "FUERTEVENTURA", "LANZAROTE"),
    values = c("#A94332", "#C99A45", "#D8B77A", "#292929")
  ) +
  theme_classic() +
  theme(
    plot.background = element_rect(fill = "transparent", color = "transparent"),
    panel.background = element_rect(fill = "transparent", color = "transparent"),
    plot.title = element_markdown(face = "bold", size = 18, hjust = .5,
                                  margin = margin(b = .75, unit = "cm")),
    axis.title = element_text(face = "bold", size = 18),
    axis.title.x = element_text(margin = margin(t = .5, unit = "cm")), 
    axis.title.y = element_text(margin = margin(r = .5, unit = "cm")),     
    axis.text = element_text(face = "bold", size = 14),
    axis.text.x = element_markdown(),
    axis.line = element_line(linewidth = 1.5), 
    axis.ticks = element_blank()
  )

ggsave(plot= plot_species_per_islands, 
       "figures/plot_species_per_islands.png",
       width = 8, height = 5)  
  
plot_species_per_islands_type <- species_per_islands_type |>
  ggplot(aes(reorder(isla_muni, n), n, fill = domain)) +
  geom_col(color = "black", size = 2,width = .5, show.legend = FALSE,
           position = "dodge") +
  geom_text(aes(isla_muni, n, label = n),
            position = position_dodge(width = .5),
            color = "black", 
            fontface = "bold",
            size=7, 
            show.legend = FALSE,
            vjust = -.5) +
  scale_y_continuous(expand = expansion(0),
                     limits = c(0, y_species_per_islands_axis)) +
  labs(
    title = "Número de especies de <span style = 'color: #870909'>animales</span> y <span style = 'color: forestgreen'>plantas</span> por islas",
    y = "Número de especies",
    x = "Isla de procedencia"
  ) +
  scale_fill_manual(
    breaks = c("Metazoa", "Plantae"),
    values = c("#870909", "forestgreen")
  ) +
  theme_classic() +
  theme(
    plot.background = element_rect(fill = "transparent", color = "transparent"),
    panel.background = element_rect(fill = "transparent", color = "transparent"),
    plot.title = element_markdown(face = "bold", size = 18, hjust = .5,
                                  margin = margin(b = .75, unit = "cm")),
    axis.title = element_text(face = "bold", size = 18),
    axis.title.x = element_text(margin = margin(t = .5, unit = "cm")), 
    axis.title.y = element_text(margin = margin(r = .5, unit = "cm")),     
    axis.text = element_text(face = "bold", size = 14),
    axis.text.x = element_markdown(),
    axis.line = element_line(linewidth = 1.5), 
    axis.ticks = element_blank(),
  )

ggsave(plot= plot_species_per_islands_type, 
       "figures/plot_species_per_islands_type.png",
       width = 8, height = 5)  

## Datos de especies en contradas en espacios naturales protegidos

## Número de observaciones que estén en ENP o NO

pne_processed <- species_db |>
  mutate(categoria = ifelse(is.na(categoria), "No ENP", categoria),
         pne_or_not = ifelse(categoria == "No ENP", "No ENP", "ENP")) %>%
  mutate(colores = case_when(
    categoria == "Monumento Natural" ~ "#004078",
    categoria == "Paisaje Protegido" ~ "#80a0bd",    
    categoria == "Reserva Natural Especial" ~ "#00913f",    
    categoria == "Reserva Natural Integral" ~ "#034a31",    
    categoria == "Parque Rural" ~ "#e60000",    
    categoria == "Sitio de Interés Científico" ~ "#BADBCA",
    categoria == "Parque Natural" ~ "#f78000",
    categoria == "Parque Nacional" ~ "#fffb39"    
  )) 

observations <- pne_processed |>
  group_by(pne_or_not, isla_muni) %>%
  count() %>%
  ungroup() %>%
  group_by(isla_muni) %>%
  mutate(
    percentage = round((n/sum(n)*100),2)
  ) %>%
  ungroup()

span <- "<span style = 'color: "

plot_observations <- observations %>%
  mutate(pne_or_not = factor(pne_or_not,
                             levels = c("No ENP", "ENP")),
         isla_muni = factor(isla_muni,
                            levels = c("GRAN CANARIA",
                                       "TENERIFE",
                                       "FUERTEVENTURA",
                                       "LANZAROTE"),
                            labels = c(glue("<strong>{span}#C99A45'>GRAN CANARIA</span></strong>"),
                                       glue("<strong>{span}#A94332'>TENERIFE</span></strong>"),
                                       glue("<strong>{span}#D8B77A'>FUERTEVENTURA</span></strong>"),
                                       glue("<strong>{span}#292929'>LANZAROTE</span></strong>"))),
         label = glue("{percentage} % ({n})")) %>%
  ggplot(aes(pne_or_not, percentage, fill = pne_or_not)) +
  geom_col(show.legend = FALSE, color = "black", width = .5, size = 1.25) +
  geom_text(aes(pne_or_not, percentage, label = label),
            position = "identity",
            color = "black", 
            fontface = "bold",
            size=4, 
            show.legend = FALSE,
            vjust = -.5) + 
  facet_wrap(~isla_muni) +
  scale_y_continuous(expand = expansion(0),
                     limits = c(0, 120),
                     breaks = seq(0,100, 25)) +
  scale_fill_manual(values = c("gray33", "red")) +
  labs(
    title = "Porcentaje de observaciones en los ENP",
    x = "En Espacio Natural Protegido¿?",
    y = "Porcentaje"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_markdown(face = "bold", size = 18, hjust = .5,
                                  margin = margin(b = .75, unit = "cm")),
    axis.title = element_text(face = "bold", size = 18),
    axis.title.x = element_text(margin = margin(t = .5, unit = "cm")), 
    axis.title.y = element_text(margin = margin(r = .5, unit = "cm")),     
    axis.text = element_text(face = "bold", size = 12, color = "black"),
    axis.text.x = element_markdown(),
    axis.ticks = element_blank(),
    strip.text = element_markdown(),
    strip.background = element_rect(fill = "white", color = "black")
  )

ggsave(plot= plot_observations, 
       "figures/plot_observations.png",
       width = 8, height = 5)  

## Espacios Protegidos de Gran Canaria:

gc_observations_pne <- pne_processed %>%
  filter(isla_muni == "GRAN CANARIA" & pne_or_not == "ENP")

## Gráfico general de las categorías de los espacios naturales protegidos

gc_species_pne <- gc_observations_pne %>%
  group_by(categoria, id_biota, colores) %>%
  count() %>%
  ungroup() %>%
  group_by(categoria, colores) %>%
  count() %>%
  ungroup()  %>%  
  arrange(desc(n)) 

y_species_gc_pne_axis <- max(gc_species_pne$n) + (max(gc_species_pne$n) * 0.2)

plot_gc_species_pne <- gc_species_pne %>%
  ggplot(aes(n, reorder(categoria,n), fill = categoria)) +
  geom_col(show.legend = FALSE, color = "black", size = 1.5) +
  geom_text(aes(n, categoria, label = n),
            position = "identity",
            color = "black", 
            fontface = "bold",
            size=7, 
            show.legend = FALSE,
            hjust = -.5) +  
  scale_x_continuous(expand = expansion(0),
                     limits = c(0, y_species_gc_pne_axis)) +
  scale_fill_manual(
    breaks = gc_species_pne$categoria,
    values = gc_species_pne$colores
  ) +
  labs(
    title = "Número de especies por ENP en Gran Canaria",
    x = "Número de Especies",
    y = NULL
  ) +
  theme_classic() +
  theme(
    panel.background = element_rect(color = "transparent", fill = "transparent"),
    plot.background = element_rect(color = "transparent", fill = "transparent"),    
    plot.title = element_markdown(face = "bold", size = 18, hjust = 1,
                                  margin = margin(b = .75, unit = "cm")),
    axis.title = element_text(face = "bold", size = 18),
    axis.title.x = element_text(margin = margin(t = .5, unit = "cm")), 
    axis.title.y = element_text(size = 14, margin = margin(r = .5, unit = "cm")),     
    axis.text = element_text(face = "bold", size = 12, color = "black"),
    axis.text.x = element_markdown(),
    axis.ticks = element_blank(),
    axis.line = element_line(linewidth = 1.5),     
  ) 

ggsave(plot= plot_gc_species_pne, 
       "figures/plot_gc_species_pne.png",
       width = 8, height = 5)  


## Especies en cada espacio natural protegido de Gran Canaria
gc_species_pne_nombre <- gc_observations_pne %>%
  group_by(codigo, nombre, categoria, id_biota, colores) %>%
  count() %>%
  ungroup() %>%
  group_by(codigo, nombre, categoria, colores) %>%
  count() %>%
  ungroup()  %>%  
  arrange(desc(n)) 

y_species_gc_pne_nombre_axis <- max(gc_species_pne_nombre$n) + (max(gc_species_pne_nombre$n) * 0.2)

plot_gc_species_pne_nombre <- gc_species_pne_nombre %>%
  mutate(nombre = str_replace(nombre, 
         pattern = "Barranco",
         replacement = "Bco."),
         nombre = glue("{nombre} ({codigo})")) %>%
  ggplot(aes(n, reorder(nombre, n), fill = categoria)) +
  geom_col(show.legend = FALSE, color = "black", size = 1) +
  geom_text(aes(n, nombre, label = n),
            position = "identity",
            color = "black", 
            fontface = "bold",
            size=6, 
            show.legend = FALSE,
            hjust = -.5) +  
  scale_x_continuous(expand = expansion(0),
                     limits = c(0, y_species_gc_pne_nombre_axis)) +
  scale_fill_manual(
    breaks = gc_species_pne_nombre$categoria,
    values = gc_species_pne_nombre$colores
  ) +
  labs(
    title = NULL,
    x = "Número de Especies",
    y = NULL
  ) +
  theme_classic() +
  theme(
    panel.background = element_rect(color = "transparent", fill = "transparent"),
    plot.background = element_rect(color = "transparent", fill = "transparent"),
    plot.title = element_markdown(face = "bold", size = 18, hjust = 0.25,
                                  margin = margin(b = .75, unit = "cm")),
    axis.title = element_text(face = "bold"),
    axis.title.x = element_text(size = 14, margin = margin(t = .5, unit = "cm")), 
    axis.text.y = element_text(size = 11, margin = margin(r = .5, unit = "cm")),     
    axis.text = element_text(face = "bold", size = 12, color = "black"),
    axis.text.x = element_markdown(),
    axis.ticks = element_blank(),
    axis.line = element_line(linewidth = 1.5),     
  )

## Mapa de Gran Canaria ENP

gc_eennpp <- eennpp %>%
  filter(str_detect(codigo, "C-"))

gc_municipios <- municipios %>%
  filter(isla == "GRAN CANARIA")

plot_gc_eennpp <- gc_eennpp %>%
  left_join(gc_species_pne_nombre, by = "codigo") %>%
  mutate(n = tidyr::replace_na(n, 0)) %>%
  st_as_sf() %>%
  ggplot() +
  geom_sf(data = gc_municipios, fill = "#fff3d8") +
  geom_sf(aes(fill = n)) +
  geom_sf_text(
    aes(label = n),
    stat = "sf_coordinates",
    size = 3,
    color = "black"
  ) +
  labs(fill = "Nº Especies") +
  scale_fill_gradient(low = "white", high = "red") +
  theme_map() +
  theme(
    plot.background = element_rect(color = "transparent", fill = "transparent"),
    pannel.background = element_rect(color = "transparent", fill = "transparent")    
  )

gc_grid_plot <- plot_grid(plot_gc_species_pne_nombre, plot_gc_eennpp,
  rel_widths = c(1.75, 1))

ggsave(plot= gc_grid_plot, 
       "figures/gc_grid_plot.png",
       width = 14, height = 7)  

##----------------------
## Estudio de Zonas ZEC
##----------------------

##-------------------------
## Estudio de Gran Canaria
##-------------------------

## Especies en cada espacio natural protegido de Gran Canaria
gc_species_zec_nombre <- gc_observations_pne %>%
  filter(str_detect(COD_LIC, "^ES")) %>%
  group_by(COD_LIC, NOMZEC, id_biota) %>%
  count() %>%
  ungroup() %>%
  group_by(COD_LIC, NOMZEC) %>%
  count() %>%
  ungroup()  %>%  
  arrange(desc(n)) 

y_species_gc_zec_nombre_axis <- max(gc_species_zec_nombre$n) + (max(gc_species_zec_nombre$n) * 0.2)

plot_gc_species_zec_nombre <- gc_species_zec_nombre %>%
  mutate(NOMZEC = str_replace(NOMZEC, pattern = "Barranco", replacement = "Bco"),
         NOMZEC = str_replace(NOMZEC, pattern = "Ojeda, Inagua y Pajonales", 
                              replacement = "Inagua"), 
         nombre = glue("{NOMZEC} {COD_LIC}"))  %>%
  ggplot(aes(n, reorder(NOMZEC, n), fill = n)) +
  geom_col(show.legend = FALSE, color = "black", size = 1) +
  geom_text(aes(n, NOMZEC, label = n),
            position = "identity",
            color = "black", 
            fontface = "bold",
            size=6, 
            show.legend = FALSE,
            hjust = -.25) +  
  scale_x_continuous(expand = expansion(0),
                     limits = c(0, y_species_gc_pne_nombre_axis)) +
  scale_fill_gradient(
    low = "white",
    high = "#4CE600"
  ) +
  labs(
    title = NULL,
    x = "Número de Especies",
    y = NULL
  ) +
  theme_classic() +
  theme(
    panel.background = element_rect(color = "transparent", fill = "transparent"),
    plot.background = element_rect(color = "transparent", fill = "transparent"),
    plot.title = element_markdown(face = "bold", size = 18, hjust = 0.25,
                                  margin = margin(b = .75, unit = "cm")),
    axis.title = element_text(face = "bold"),
    axis.title.x = element_text(size = 16, margin = margin(t = .5, unit = "cm")), 
    axis.text.y = element_text(size = 11, margin = margin(r = .5, unit = "cm")),     
    axis.text = element_text(face = "bold", size = 11, color = "black"),
    axis.text.x = element_markdown(),
    axis.ticks = element_blank(),
    axis.line = element_line(linewidth = 1.5),     
  )

ggsave(plot= plot_gc_species_zec_nombre, 
       "figures/plot_gc_species_zec.png",
       width = 8, height = 5)  

## Mapa de Gran Canaria ENP

gc_zec <-  zec %>%
  filter(str_detect(NUM_ZEC, "_GC"))

gc_zec_species <- gc_zec %>%
  filter(AMBITO == "Terrestre") %>%
  left_join(gc_species_zec_nombre, by = "COD_LIC") %>%
  mutate(n = tidyr::replace_na(n, 0)) %>%
  st_as_sf() %>%
  ggplot() +
  geom_sf(data = gc_municipios, fill = "#fff3d8") +
  geom_sf(aes(fill = n)) +
  geom_sf_text(
    aes(label = n),
    stat = "sf_coordinates",
    size = 3,
    color = "black"
  ) +
  labs(fill = "Nº Especies") +
  scale_fill_gradient(low = "white", high = "#4CE600") +
  theme_map() +
  theme(
    plot.background = element_rect(color = "transparent", fill = "transparent"),
    pannel.background = element_rect(color = "transparent", fill = "transparent"),
    legend.position = "Bottom"
  )

gc_grid_plot_zec <- plot_grid(
  plot_gc_species_zec_nombre,
  gc_zec_species,
  rel_widths = c(1.75, .75)
)

ggsave(plot= gc_grid_plot_zec, 
       "figures/gc_grid_plot_zec.png",
       width = 16, height = 7)  
