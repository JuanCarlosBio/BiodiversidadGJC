#!/usr/bin/env Rscript

## Testear si no se me ha colado ninguna especie donde no debería

library(tidyverse)

species <- read_tsv("data/species/processed/coord_plantae.tsv")

centinela_species <- read_delim(
  "data/biota/raw/centinela_species.csv", 
  delim = ";", 
  locale=readr::locale(encoding="latin1")
  ) %>%
  select(scientific_name = `Nombre especie/subespecie`)  

print("-------------------------------------------------------------------")
print(">>> There should only be 'Especie protegida' - 'Especie traslocada'")
print("-------------------------------------------------------------------")

filtering <- species %>%
  filter(scientific_name %in% centinela_species$scientific_name) %>%
  group_by(category) %>%
  count() 

filtering$category
