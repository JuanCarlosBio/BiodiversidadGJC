#!/usr/bin/env bash

biota_link="https://www.biodiversidadcanarias.es/biota/especies/export?pagina=1&tipoBusqueda=NOMBRE&searchSpeciesTabs=fastSearchTab&orderBy=nombreCientifico&orderForm=true"

wget -P data/ -O data/biota_species.csv $biota_link -N