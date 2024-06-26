#!/usr/bin/env Rscript

suppressMessages(suppressWarnings({
  library(glue)
  library(tidyverse)
  library(exifr)
}))

## Primeto se descargarán las imágenes de plantas y posteriormente de los metazoos. 
## el iterador org = organism (organismo) 
for (org in c("dropbox_links_plantae", "dropbox_links_metazoa")){

	## Se descargarán las imágenes a partir de los links de los archivos de  metadata/
	suppressMessages(suppressWarnings({
	  metadata <- read_csv(glue("metadata/{org}.csv"), 
	                       col_names = FALSE)
	})) 
		
          ## Como el csv de los metadatos está compuesto de una sola columna, podemos
          ## seleccionar los links como un vector con X1
	  links <- metadata$X1

          ## Creamos listas vacías con la información de las imágenes (metadados) de interés:
          ## * Sourcefile: Ruta y nombre del archivo JPG con la especie
          ## * Filename: Nombre del archivo JPG
          ## * GPSDatatime: Fecha y Hora donde se tomó la foto
          ## * GPSPosition: Longitud y Latitud de la foto	
          ## * GPSAltitude: Altitud donde se tomó la foto
	  list_sourcefile <- c()
	  list_filename <- c()
	  list_gpsdatetime <- c()
	  list_gpsposition <- c()
	  list_gpsaltitude <- c()

          ## Los links en formato de vector lo añadimos a un segundo bucle. 
	  for (link in links){
              ## Primera parte de descarga de datos
	      print(glue(glue(">>> Se están descargando los archivos de {org}")))
	      system(glue(glue('wget -P images/ -O images/{org}.zip "{link}" -N -q')))
				## Para ello además hay que descomprimir el archivo zip de la carpetac on las imágenes	
	      unzip(glue("images/{org}.zip"), exdir = glue("images/{org}"))
	
              ## Este condicional es para prevenir errores, como lo que se descargan son varias carpetas
              ## si he añadido alguna nueva pero no hay fotos en ella, dirá que no se encuentran fotos, 
              ## por el contrario si hay fotos, se continúa con la creación de los vectores con los me_
              ## tadados de las imágenes para cada parámetro especificado anteriormente.
	      archivos <- list.files(glue("images/{org}"), full.names = TRUE)

	      if (length(archivos) > 0) {
	          exif_file <- read_exif(archivos) |> 
	              rename_all(tolower) 

                  ## Creamos vectores con la información de interés y se concatenan dependiendo de 
                  ## cuantas carpetas tengamod en los metadatos/links_*
	          list_sourcefile <- c(list_sourcefile, exif_file$sourcefile)
	          list_filename <- c(list_filename, exif_file$filename)
	          list_gpsdatetime <- c(list_gpsdatetime, exif_file$gpsdatetime)
	          list_gpsposition <- c(list_gpsposition, exif_file$gpsposition)
	          list_gpsaltitude <- c(list_gpsaltitude, exif_file$gpsaltitude)
	
	        print(glue(glue(">>> Se Han descargado los archivos de {org}")))
	      } else {
	        print("No hay archivos en el directorio especificado.")
	      }
              ## Cuando se guarden en la memoria la información de los metadatos en los vectores
              ## de R, se eliminan las fotos dentro del la carpeta images/. La razónde hacerlo de
              ## esta manera, es que al haber gran cantidad de imágenes, no hay memoria que pueda
              ## guardarla en la máquina virtual de GitHub Actions
	      system("rm -rf images/*;touch images/README.txt")
	  }
	
	  ## Combinar los vectores con la información en un Data Frame
	  combined_df <- data.frame(sourcefile = list_sourcefile,
	                            filename = list_filename,
	                            gpsdatetime = list_gpsdatetime,
	                            gpsposition = list_gpsposition,
	                            gpsaltitude = list_gpsaltitude) 
	
	  ## Guardar el data frame combinado si es necesario. De esta manera tenemos un 
          ## Archivo TSV para cada organismo, sin imágenes de por medio, es mucho más
          ## pequeño un archivo de este tipo que un JPG.
	  write_tsv(combined_df, glue("data/raw_{org}_content.tsv")) 
}
