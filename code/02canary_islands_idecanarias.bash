#!/usr/bin/env bash

url_muni=https://opendata.sitcan.es/upload/unidades-administrativas/gobcan_unidades-administrativas_municipios.zip
url_pne=https://opendata.sitcan.es/upload/medio-ambiente/eennpp.zip 

wget -P data/ $url_muni -N  
wget -P data/ $url_pne -N 

mkdir -p data/islands_shp

unzip data/gobcan_unidades-administrativas_municipios.zip -d data/islands_shp
unzip data/eennpp.zip -d data/islands_shp