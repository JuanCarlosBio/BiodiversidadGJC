#!/usr/bin/env bash

url_muni=https://opendata.sitcan.es/upload/unidades-administrativas/gobcan_unidades-administrativas_municipios.zip
url_pne=https://opendata.sitcan.es/upload/medio-ambiente/eennpp.zip 
url_zec=https://opendata.sitcan.es/upload/medio-ambiente/gobcan_medio-ambiente_zec-zonificacion.zip 

wget -P data/ $url_muni -N -q 
wget -P data/ $url_pne -N -q
wget -P data/ $url_zec -N -q

mkdir -p data/islands_shp

unzip data/gobcan_unidades-administrativas_municipios.zip -d data/islands_shp
unzip data/eennpp.zip -d data/islands_shp
unzip data/gobcan_medio-ambiente_zec-zonificacion.zip -d data/islands_shp

rm data/gobcan_unidades-administrativas_municipios.zip data/eennpp.zip data/gobcan_medio-ambiente_zec-zonificacion.zip 