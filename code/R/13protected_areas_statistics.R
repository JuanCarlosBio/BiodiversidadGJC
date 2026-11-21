
library(tidyverse)
library(gt)
library(ggtext)

species_db <- read_csv("data/species/processed/species_data_base.csv")

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

species_per_islands |>
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
    axis.ticks = element_blank(),
  )
  
species_per_islands_type |>
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
    title = "Número de especies por islas, según el dominio",
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

