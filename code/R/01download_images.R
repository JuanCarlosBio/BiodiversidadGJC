#!/usr/bin/env Rscript
suppressMessages(suppressWarnings({
  library(glue)
  library(tidyverse)
  library(exifr)
}))

for (org in c("dropbox_links_plantae", "dropbox_links_metazoa")){

suppressMessages(suppressWarnings({
  metadata <- read_csv(glue("metadata/{org}.csv"), 
                       col_names = FALSE)
})) 

  links <- metadata$X1

  list_sourcefile <- c()
  list_filename <- c()
  list_gpsdatetime <- c()
  list_gpsposition <- c()
  list_gpsaltitude <- c()

  for (link in links){
      print(glue(glue(">>> Se están descargando los archivos de {org}")))
      system(glue(glue('wget -P images/ -O images/{org}.zip "{link}" -N -q')))

      unzip(glue("images/{org}.zip"), exdir = glue("images/{org}"))

      archivos <- list.files(glue("images/{org}"), 
                      full.names = TRUE)
      if (length(archivos) > 0) {
          exif_file <- read_exif(archivos) |> 
              rename_all(tolower) 

          list_sourcefile <- c(list_sourcefile, exif_file$sourcefile)
          list_filename <- c(list_filename, exif_file$filename)
          list_gpsdatetime <- c(list_gpsdatetime, exif_file$gpsdatetime)
          list_gpsposition <- c(list_gpsposition, exif_file$gpsposition)
          list_gpsaltitude <- c(list_gpsaltitude, exif_file$gpsaltitude)

        print(glue(glue(">>> Se Han descargado los archivos de {org}")))
      } else {
        print("No hay archivos en el directorio especificado.")
      }

      system("rm -rf images/*;touch images/README.txt")
  }

  # Combinar todos los data frames en uno solo
  combined_df <- data.frame(sourcefile = list_sourcefile,
                            filename = list_filename,
                            gpsdatetime = list_gpsdatetime,
                            gpsposition = list_gpsposition,
                            gpsaltitude = list_gpsaltitude) 

  # Guardar el data frame combinado si es necesario
  write_tsv(combined_df, glue("data/raw_{org}_content.tsv")) 
}