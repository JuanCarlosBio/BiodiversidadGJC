#!/usr/bin/env Rscript

library(glue)
library(tidyverse)
library(exifr)

metadata <- read_csv("../../metadata/metadata.csv", col_names = c("codigo", "flora_vascular", "invertebrados"))
for (org in c("flora_vascular", "invertebrados")){
links <- metadata[,glue("{org}")] |> as.vector() |> unlist()

list_sourcefile <- c()
list_filename <- c()
list_gpsdatetime <- c()
list_gpsposition <- c()
list_gpslatitude <- c()

for (link in links){
    system(glue(glue('wget -P carpeta/ -O carpeta/{org}.zip "{link}" -N -q')))

    unzip(glue("carpeta/{org}.zip"), exdir = glue("carpeta/{org}"))

    archivos <- list.files(glue("carpeta/{org}"), 
                    full.names = TRUE)
    if (length(archivos) > 0) {
        exif_file <- read_exif(archivos) |> 
            rename_all(tolower) 

        list_sourcefile <- c(list_sourcefile, exif_file$sourcefile)
        list_filename <- c(list_filename, exif_file$filename)
        list_gpsdatetime <- c(list_gpsdatetime, exif_file$gpsdatetime)
        list_gpsposition <- c(list_gpsposition, exif_file$gpslongitude)
        list_gpslatitude <- c(list_gpslatitude, exif_file$gpsaltitude)

      print(glue(glue("Habían archivos en el directorio de {org}")))
    } else {
      print("No hay archivos en el directorio especificado.")
    }

    system("rm -rf carpeta/*;touch README.txt")
}

# Combinar todos los data frames en uno solo
combined_df <- data.frame(sourcefile = list_sourcefile,
                          filename = list_filename,
                          gpsdatetime = list_gpsdatetime,
                          gpslongitude = list_gpsposition,
                          gpsaltitude = list_gpslatitude) 

# Guardar el data frame combinado si es necesario
write_csv(combined_df, glue("coord_{org}.csv")) 
}