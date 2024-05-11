#!/usr/bin/env bash

for line in images/flora_vascular/*jpg; do
    filename=$(basename "$line")  # Obtener solo el nombre del archivo sin la ruta
    new_filename=$(echo "$filename" | cut -d "-" -f 1,2,3,9,10,11,12,13,14,15)  # Generar el nuevo nombre de archivo
    mv "$line" "images/flora_vascular/$new_filename"  # Mover el archivo con el nuevo nombre
done


for line in images/invertebrados/*jpg; do
    filename=$(basename "$line")  # Obtener solo el nombre del archivo sin la ruta
    new_filename=$(echo "$filename" | cut -d "-" -f 1,2,3,10,11,12,13,14,15)  # Generar el nuevo nombre de archivo
    mv "$line" "images/invertebrados/$new_filename"  # Mover el archivo con el nuevo nombre
done
