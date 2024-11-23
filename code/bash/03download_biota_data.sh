#!/usr/bin/env bash

biota_link="https://www.biodiversidadcanarias.es/biota/especies/export?pagina=1&tipoBusqueda=NOMBRE&searchSpeciesTabs=fastSearchTab&orderBy=nombreCientifico&orderForm=true"
centinela_link="https://www.biodiversidadcanarias.es/centinela/especies/export?pagina=1&tipoBusqueda=NOMBRE"

## Descargar los datos de Biota
wget -P data/ -O data/biota/raw/biota_species.csv $biota_link -N -q

## Descargar los datos de Centinela
wget -P data/ -O data/biota/raw/centinela_species.csv $centinela_link -N -q