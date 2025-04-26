#!/usr/bin/env Rscript

suppressMessages(suppressWarnings({
    library(dplyr)
    library(readr)
    library(tidyr)
    library(stringr)
    library(lubridate)
}))

## -> Ahora que lo vuelvo a visitar a día de 18/11/2024 digo que este código 
## funciona e maravilla a pesar de ser BASURA xd, tengo pensado como solucionar 
## esta locura pero necesito tiempo para mentalizarme en cambiar este desastre

## -> 24/11/2024, bueno mejorando, pero quedan cosas que limpiar, quiero quitar 
## algún campo más

data_biota <- read_tsv("data/biota/processed/biota_data_processed.tsv")
protected_species_layer <- read_tsv("data/protected_species/coord_plantae_pe.tsv")

##==============================================================================
## INFORMACIÓN:
## Función para procesar la columna "filename" de los EXIF de las fotogragías 
## de las especies, ya que son etiquetas con información extra, obtenida a 
## partir e BIOCAN, Gobierno de Canairas: https://www.biodiversidadcanarias.es/
## ARGUMENTOS:
##     path: Ruta donde se encuentran las fotografías
##     id_specie_start: comienzo del indetificador de las especies (FV=Plantae,
##                       AI=Metazoa)
## Resultado:
##     Data Frame con los datos de los EXIF procesados.
## EJEMPLO:
##     rp_species(path = "path/to/speices_plantae.tsv", id_specie_start = "^FV")
##==============================================================================
rp_species <- read_and_processed_species_data <- function(path, id_specie_start)
{
    df_species_processed = read_tsv(path) |>
        mutate(
            filename = str_replace(filename, pattern = ".jpg", replacement = "")
        ) |>
        filter(
            !(str_detect(filename,  "NO CLASIFICADO")) & 
            str_detect(filename, id_specie_start) & 
            str_count(filename, "-") == 7
        ) |> 
        separate_wider_delim(
            gpsposition, 
            delim = " ", 
            names = c("latitude", "longitude")
        ) |>
        mutate(
            latitude = as.numeric(latitude), 
            longitude = as.numeric(longitude)
        ) |>
        separate_wider_delim(
            filename, 
            delim = "-",
            names = c(
               "id", 
               "specie", 
               "endemic_genus", 
               "endemic_specie", 
               "endemic_subspecie",
               "origin", 
               "category", 
               "id_biota"
            )
        ) |>
        mutate(
    	endemic_genus = case_when(
                endemic_genus == "eg_no" ~ "NO",
                endemic_genus == "eg_si" ~ "SI",
                !(endemic_subspecie == "eg_no") |
                    !(endemic_subspecie == "eg_no") ~ "-"
    	    ),
            endemic_specie = case_when(
                endemic_specie == "ee_no" ~ "NO",
                endemic_specie == "ee_si" ~ "SI",
                !(endemic_subspecie == "ee_no") |
                    !(endemic_subspecie == "ee_no") ~ "-"
    	    ),
            endemic_subspecie = case_when(
                endemic_subspecie == "es_no" ~ "NO",
                endemic_subspecie == "es_si" ~ "SI",
                !(endemic_subspecie == "es_no") |
                    !(endemic_subspecie == "es_no") ~ "-"
    	    ),
            origin = case_when(
                origin == "ns" ~ "Nativo seguro", 
                origin == "np" ~ "Nativo probable", 
                origin == "isi" ~ "Introducido seguro invasor", 
                origin == "isn" ~ "Introducido seguro no invasor", 
                origin == "ip" ~ "Introducido probable",
                origin == "isp" ~ "Introducido seguro potencialmente invasor"
    	    ),
            category = case_when(
    	        category == "ep" ~ "Especie protegida",
                category == "ei" ~ "Especie introducida",
                category == "et" ~ "Especie traslocada",
                !(category == "ep") | !(category == "ei") ~ "Especie nativa"
    	    ),
            gpsdatetime = ymd_hms(gpsdatetime),
            gpsdatetime = format(gpsdatetime, "%d/%m/%Y")) |> 
        inner_join(data_biota, ., by="id_biota") |> 
        select(-subdivision, division)

    return(df_species_processed)

}

metazoa <- rp_species(
    path="data/species/raw/raw_dropbox_links_metazoa_content.tsv", 
    id_specie_start="^MENP"
    ) 
# |> 
# readr::write_tsv("data/species/processed/coord_invertebrates.tsv") 

plantae <- rp_species(
    path="data/species/raw/raw_dropbox_links_plantae_content.tsv", 
    id_specie_start="^PANP"
    ) 
# |>
# bind_rows(protected_species_layer) |>

rbind(metazoa, plantae) |>
    bind_rows(protected_species_layer) |>
    readr::write_tsv("data/species/processed/coord_species.tsv")
