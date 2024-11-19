#!/usr/bin/env Rscript

df_biota <- readr::read_delim("data/biota/raw/biota_species.csv", delim = ";", 
                              locale=readr::locale(encoding="latin1")) |> 
    dplyr::select(
        "id_biota" = `Código`,
        "name"=`Nombre común/vulgar`,
        "medium"=Medio ,
        "class" = Clase,
        "family" = Familia,
        "endemicity" = Endemicidad,
        "domain" = Reino,
        "division" = `División`,
        "subdivision" = `Subdivisión`,
        "phylo" = Filo,
        "order" = Orden ,
        "presence" = Presencia 
    ) |>
    readr::write_tsv("data/biota/processed/biota_data_processed.tsv")

