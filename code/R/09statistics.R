#!/usr/bin/env Rscript

suppressMessages(suppressWarnings({
  library(dplyr)
  library(stringr)
  library(readr)
  library(ggplot2)
  library(tidyr)
  library(ggtext)
  library(sf)
  library(gt)
}))

##----------------------------------------------------------------------------#

## Loding scripts and fonts 

## Loading the data ##
exif_data_ai <- read_tsv("data/species/raw/raw_dropbox_links_metazoa_content.tsv")
exif_data_fv <- read_tsv("data/species/raw/raw_dropbox_links_plantae_content.tsv")
invertebrates <- read_tsv("data/species/processed/coord_invertebrates.tsv")
plantae <- read_tsv("data/species/processed/coord_plantae.tsv") 
enp_map <- read_sf("data/gran_canaria_shp/gc_pne.shp")
map <- read_sf("data/gran_canaria_shp/gc_muni.shp") |>
  st_transform(map, crs = 4326) 

# Procesado de datos
enp_map_processed <- enp_map |>
  st_transform(map, crs = 4326) |>
  mutate(categoria = factor(categoria,
                            levels = c("Monumento Natural", 
                                       "Paisaje Protegido",
                                       "Parque Natural", 
                                       "Parque Rural", 
                                       "Reserva Natural Especial",
                                       "Reserva Natural Integral", 
                                       "Sitio de Interés Científico")))

invertebrates_processed <- invertebrates |>
  mutate(family = str_to_title(family),
         order = str_to_title(order),
         class = str_to_title(class), 
         phylo = str_to_title(phylo))

plantae_processed <- plantae |> 
  mutate(family = str_to_title(family),
         order = str_to_title(order),
         class = str_to_title(class), 
         division = str_to_title(division))

##----------------------------------------------------------------------------#
## Nº de Especies clasificadas y sin clasificar
##----------------------------------------------------------------------------#

exif_data_ai |>
  select(filename) |>
  mutate(
    clasificados = case_when(
      str_detect(filename, pattern = "NO CLASIFICADO") ~ "no clasificada",
      !(str_detect(filename, pattern = "NO CLASIFICADO")) ~ "clasificada"
    )
  ) |>
  group_by(clasificados) |>
  count() -> tabla_n_ai

plantae |>
  rename_all(tolower) |>
  nrow() -> tabla_n_fv

##----------------------------------------------------------------------------#
## Primer gráfico nº 1 mapa de portada
##----------------------------------------------------------------------------#

coord_invertebrates <- invertebrates_processed |>
  select(domain, latitude, longitude) 

coord_plantae <- plantae_processed |>
  select(domain, latitude, longitude)

coord_invert_plantae <- rbind(coord_invertebrates, coord_plantae)

species_plot <- coord_invert_plantae |>
  ggplot() +
  geom_sf(data = map, fill = "#edd393") +
  geom_sf(data = enp_map_processed, aes(fill = categoria),
          alpha = .3, show.legend = FALSE) +
  geom_point(data = coord_invert_plantae, 
             aes(longitude, latitude, color = domain),
             size = .5, show.legend = FALSE) +
  coord_sf() +
  scale_color_manual(
    breaks = c("Metazoa", "Plantae"),
    values = c("red", "forestgreen")) +  
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
  labs(
    title = "<span style = 'color: #870909'>ANIMALES</span> Y <span style = 'color: forestgreen'>PLANTAS</span> IDENTIFICADOS!!!"
  ) +
  theme_test() +
  theme(
    plot.title = element_markdown(size = 4, face = "bold", hjust = .5),
    plot.background = element_rect(color = "#fff3d8", fill = "#fff3d8"),
    panel.background = element_rect(color= "#cfe8fc", fill = "#cfe8fc"),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) +
  #guides(color = FALSE) +
  labs(
    x = NULL, y = NULL,
    fill = NULL, color = NULL
  );species_plot

ggsave(plot= species_plot, 
       "figures/GC_mapa.png",
       width = 1.5, height = 1.5)  

##----------------------------------------------------------------------------#
## Númerod de especies encontradas según su Reino
##----------------------------------------------------------------------------#

invertebrates_domain <- invertebrates |>
  select(domain, id_biota)

plantae_domain <- plantae |>
  select(domain,id_biota)

plantaed_invertebratesd <- rbind(invertebrates_domain, plantae_domain)

plad_invdp <- plantaed_invertebratesd |>
  group_by(domain, id_biota) |>
  count() |>
  ungroup() |>
  group_by(domain) |>
  count() |>
  mutate(domain = factor(domain, levels = c("Metazoa", "Plantae"))) 

y_domain_axis <- max(plad_invdp$n) + (max(plad_invdp$n) * 0.2)

metazoa_plantae_plot <- plad_invdp |>
  ggplot(aes(domain, n, fill = domain)) +
  geom_col(color = "black", size = 2,width = .3, show.legend = FALSE) +
  geom_text(aes(domain, n, label = n),
            position = "identity",
            color = "black", 
            fontface = "bold",
            size=7, 
            show.legend = FALSE,
            vjust = -.5) +
  scale_fill_manual(values = c("#870909", "forestgreen")) +
  scale_y_continuous(expand = expansion(0),
                     limits = c(0, y_domain_axis)) +
  scale_x_discrete(breaks = c("Metazoa", "Plantae"),
                   labels = c("<span style = 'color: #870909'>Metazoa</span>", "<span style = 'color: forestgreen'>Plantae</span>")) +
   labs(
     title = "Especies de <span style = 'color: #870909'>*ANIMALES*</span> y <span style = 'color: forestgreen'>*PLANTAS*</span>",
     y = "Nº de especies",
     x = "Reino"
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
  );metazoa_plantae_plot  

ggsave(plot= metazoa_plantae_plot, 
       "figures/n_plantae_metazoa.png",
       width = 8, height = 5)  

##----------------------------------------------------------------------------#
## Segundo gráfico nº 2 de metazoos y plantae
##----------------------------------------------------------------------------#

endemic_invertebrates <- invertebrates |>
  select(endemic_genus, endemic_specie, endemic_subspecie, latitude, longitude, scientific_name) 

n_endemic_invertebrates <- endemic_invertebrates |>
  group_by(endemic_genus, endemic_specie, endemic_subspecie, scientific_name) |>
  count() |>
  mutate(organism = "invertebrates") |>
  ungroup() |>
  pivot_longer(-c(organism, scientific_name, n)) 

endemic_plantae <- plantae |>
  select(endemic_genus, endemic_specie, endemic_subspecie, latitude, longitude, scientific_name) 

n_endemic_plantae <- endemic_plantae |>
  group_by(endemic_genus, endemic_specie, endemic_subspecie, scientific_name) |>
  count() |>
  mutate(organism = "plantae") |>
  ungroup() |>
  pivot_longer(-c(organism, scientific_name, n))

endemic_organisms <- rbind(n_endemic_invertebrates, n_endemic_plantae)

endemic_organisms_count <- expand.grid(organism=as.character(unique(as.character(endemic_organisms$organism))),
                                       name=as.character(unique(as.character(endemic_organisms$name))),
                                       value=as.character(unique(as.character(endemic_organisms$value)))) |> 
  left_join(endemic_organisms |> group_by(organism,name,value) %>% summarize(n=(n())),
            by=c("organism","name","value")) |> 
  mutate(n=ifelse(is.na(n),0,n)) |>
  ungroup()

endemism_table <- endemic_organisms_count |>
  filter(value != "-") |> 
  mutate(name = case_when(name == "endemic_genus" ~ "Genero",
                          name == "endemic_specie" ~ "Especie",
                          name == "endemic_subspecie" ~ "Subespecie"),
        organism = case_when(organism == "plantae" ~ "Plantae",
                             organism == "invertebrates" ~ "Metazoa"), 
        name_value = paste0(name, "_", value)) |>
        select(-name, -value) |>
  pivot_wider(id_cols = organism, names_from=name_value, values_from=n)

gt_endemism <- endemism_table |>
  gt(rowname_col = "organism") |>
  cols_align(
    align = "center"
  ) |>
  tab_header(
    title = md("**Endemicidad de los organismos (Canarias) según:\ngénero, especie y subespecie**")
  ) |>
  cols_label(
    Genero_NO = "NO",
    Genero_SI = "SI",
    Especie_NO = "NO",
    Especie_SI = "SI",
    Subespecie_NO = "NO",
    Subespecie_SI = "SI",
  ) |>
  tab_spanner(
    label = "Géneros",
    columns = c("Genero_NO", "Genero_SI") 
  ) |>
  tab_spanner(
    label = "Especies",
    columns = c("Especie_NO", "Especie_SI") 
  ) |>
  tab_spanner(
    label = "Subespecies",
    columns = c("Subespecie_NO", "Subespecie_SI") 
  ) |>
  tab_options(
    table.background.color = "#fff3d8"
  ) 

##----------------------------------------------------------------------------#
## Estadísticas de las Especies Nativas, Protegidas e Introducidas/traslocadas
##----------------------------------------------------------------------------#

# Procesado de datos
category_invertebrates <- invertebrates |>
  group_by(id_biota, category) |>
  count() |>
  ungroup() |>
  group_by(category) |>
  count() |>
  mutate(category = factor(category,
                           levels = c("Especie nativa", "Especie protegida", "Especie introducida"),
                           labels = c("Nativas", "Protegidas", "Introducidas")))

category_plantae <- plantae |>
  group_by(id_biota, category) |>
  count() |>
  ungroup() |>
  group_by(category) |>
  count() |>
  mutate(category = factor(category,
                           levels = c("Especie nativa", "Especie protegida", "Especie introducida", "Especie traslocada"),
                           labels = c("Nativas", "Protegidas", "Introducidas", "Traslocadas")))

# Gráfico de los invertebrados
y_category_animal_axis <- max(category_invertebrates$n) + (max(category_invertebrates$n) * 0.2)

category_invertebrate_plot <- category_invertebrates  |>
  ggplot(aes(category, n, fill = category)) +
  geom_col(color = "black", size = 2,width = .3, show.legend = FALSE) +
  geom_text(aes(category, n, label = n),
             color = "black", 
             fontface = "bold",
             size=7, 
             show.legend = FALSE,
             vjust = -.5) +
  scale_fill_manual(values = c("#59ff00", "#2600ff", "#ff0000")) +
  scale_y_continuous(expand = expansion(0),
                     limits = c(0, y_category_animal_axis)) +
   labs(
     title = "Especies de <span style = 'color: #870909'>*ANIMALES*</span> categorizadas según sean:", 
     subtitle = "<span style = 'color: #59ff00'>*Nativas* (no protegidas)</span>, <span style = 'color: #2600ff'>*Protegidas*</span> o <span style = 'color: #ff0000'>*Introducidas*</span>",
     y = "Nº de especies",
     x = "Especies"
  ) + 
  theme_classic() +
  theme(
    plot.background = element_rect(fill = "transparent", color = "transparent"),
    panel.background = element_rect(fill = "transparent", color = "transparent"),
    plot.title = element_markdown(face = "bold", size = 18, hjust = .5, 
                                  margin = margin(b = .5, unit = "cm")),
    plot.subtitle = element_markdown(face = "bold", size = 16, hjust = .5, 
                                     margin = margin(b = .75, unit = "cm")), 
    axis.title = element_text(face = "bold", size = 18),
    axis.title.x = element_text(margin = margin(t = .5, unit = "cm")), 
    axis.title.y = element_text(margin = margin(r = .5, unit = "cm")),     
    axis.text = element_text(face = "bold", size = 14),
    axis.text.x = element_markdown(),
    axis.line = element_line(linewidth = 1.5), 
    axis.ticks = element_blank(),
  );category_invertebrate_plot 

ggsave(plot= category_invertebrate_plot, 
       "figures/n_category_invertebrates.png",
       width = 8, height = 5)  

# Gráfico para plantas
y_category_planta_axis <- max(category_plantae$n) + (max(category_plantae$n) * 0.2)

category_plantae_plot <- category_plantae  |>
  ggplot(aes(category, n, fill = category)) +
  geom_col(color = "black", size = 2,width = .3, show.legend = FALSE) +
  geom_text(aes(category, n, label = n),
            color = "black", 
            fontface = "bold",
            size=7, 
            show.legend = FALSE,
            vjust = -.5) +
  scale_fill_manual(values = c("#59ff00", "#2600ff", "#ff0000", "#ffae00")) +
  scale_y_continuous(expand = expansion(0),
                     limits = c(0, y_category_planta_axis)) +
   labs(
     title = "Especies de <span style = 'color: forestgreen'>*PLANTAS*</span> categorizadas según sean:", 
     subtitle = "<span style = 'color: #59ff00'>*Nativas* (no protegidas)</span>, <span style = 'color: #2600ff'>*Protegidas*</span> o <span style = 'color: #ff0000'>*Introducidas*</span>/<span style = 'color: #ffae00'>*Traslocadas*</span>",
     y = "Nº de especies",
     x = "Especies"
  ) + 
  theme_classic() +
  theme(
    plot.background = element_rect(fill = "transparent", color = "transparent"),
    panel.background = element_rect(fill = "transparent", color = "transparent"),
    plot.title = element_markdown(face = "bold", size = 18, hjust = .5, 
                                  margin = margin(b = .5, unit = "cm")),
    plot.subtitle = element_markdown(face = "bold", size = 14, hjust = .5, 
                                     margin = margin(b = .75, unit = "cm")),
    axis.title = element_text(face = "bold", size = 18),
    axis.title.x = element_text(margin = margin(t = .5, unit = "cm")), 
    axis.title.y = element_text(margin = margin(r = .5, unit = "cm")),     
    axis.text = element_text(face = "bold", size = 14),
    axis.text.x = element_markdown(),
    axis.line = element_line(linewidth = 1.5), 
    axis.ticks = element_blank(),
  );category_plantae_plot 

ggsave(plot= category_plantae_plot, 
       "figures/n_category_plantae.png",
       width = 8, height = 5)  
