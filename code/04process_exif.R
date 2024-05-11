#!/usr/bin/env Rscript

data_biota <- readr::read_tsv("data/biota_data_processed.tsv")

unzip("images/flora_vascular.zip", exdir = "images/flora_vascular")
unzip("images/invertebrados.zip", exdir = "images/invertebrados")

ai_files <- list.files("images/invertebrados/", 
                    full.names = TRUE)
fv_files <- list.files("images/flora_vascular/", 
                    full.names = TRUE)

exif_data_ai <- exifr::read_exif(ai_files)
exif_data_fv <- exifr::read_exif(fv_files)

t_replacement <- c("_ta_" = "á","_te_" = "é","_ti_" = "í", "_to_" = "ó", "_tu_" = "ú", "_enie_" = "ñ")

exif_data_ai |>
    dplyr::rename_all(tolower) |>
    dplyr::select(filename, gpsdatetime, gpsposition,gpsaltitude) |>
    dplyr::mutate(filename = stringr::str_replace(filename, pattern = ".jpg", replacement = "")) |>
    dplyr::filter(!(stringr::str_detect(filename,  "NO CLASIFICADO")) & stringr::str_detect(filename, "^AI")) |>
    tidyr::separate_wider_delim(gpsposition, delim = " ",
                                names = c("latitude", "longitude")) |>
    dplyr::mutate(latitude = as.numeric(latitude),
                  longitude = as.numeric(longitude)) |>
    tidyr::separate_wider_delim(filename, delim = "-",
                                names = c("id", "specie", "author", 
                                          "endemic_genus", "endemic_specie", "endemic_subspecie",
                                          "origin", "category", "id_biota")) |>
    dplyr::mutate(endemic_genus = dplyr::case_when(endemic_genus == "eg_no" ~ "NO",
                                                   endemic_genus == "eg_si" ~ "SI",
                                                   !(endemic_subspecie == "eg_no") | !(endemic_subspecie == "eg_no") ~ "-"),
                  endemic_specie = dplyr::case_when(endemic_specie == "ee_no" ~ "NO",
                                                    endemic_specie == "ee_si" ~ "SI",
                                                    !(endemic_subspecie == "ee_no") | !(endemic_subspecie == "ee_no") ~ "-"),
                  endemic_subspecie = dplyr::case_when(endemic_subspecie == "es_no" ~ "NO",
                                                       endemic_subspecie == "es_si" ~ "SI",
                                                       !(endemic_subspecie == "es_no") | !(endemic_subspecie == "es_no") ~ "-"),
                  origin = dplyr::case_when(origin == "ns" ~ "Nativo seguro", origin == "np" ~ "Nativo probable", 
                                            origin == "isi" ~ "Introducido seguro invasor", origin == "isn" ~ "Introducido seguro no invasor", 
                                            origin == "ip" ~ "Introducido probable"),
                  category = dplyr::case_when(category == "ep" ~ "Especie protegida",
                                              category == "ei" ~ "Especie introducida",
                                              !(category == "ep") | !(category == "ei") ~ "-"),
                  author = stringr::str_replace_all(author, t_replacement)) |> 
    dplyr::inner_join(data_biota, ., by="id_biota") |> 
    dplyr::select(-subdivision, division) |> 
    readr::write_tsv("data/coord_invertebrates.tsv")


exif_data_fv |>
    dplyr::rename_all(tolower) |>
    dplyr::select(filename, gpsdatetime, gpsposition, gpsaltitude) |>
    dplyr::mutate(filename = stringr::str_replace(filename, pattern = ".jpg", replacement = "")) |>
    dplyr::filter(!(stringr::str_detect(filename,  "NO CLASIFICADO")) & stringr::str_detect(filename, "^FV")) |>
    tidyr::separate_wider_delim(gpsposition, delim = " ",
                                names = c("latitude", "longitude")) |>
    dplyr::mutate(latitude = as.numeric(latitude),
                  longitude = as.numeric(longitude)) |>
    tidyr::separate_wider_delim(filename, delim = "-",
                                names = c("id", "specie", "author",
                                          "endemic_genus", "endemic_specie", "endemic_subspecie",
                                          "origin", "category", "habitat", "id_biota")) |>
    dplyr::mutate(endemic_genus = dplyr::case_when(endemic_genus == "eg_no" ~ "NO",
                                                   endemic_genus == "eg_si" ~ "SI",
                                                   !(endemic_genus == "eg_no") | !(endemic_genus == "eg_no") ~ "-"),
                  endemic_specie = dplyr::case_when(endemic_specie == "ee_no" ~ "NO",
                                                    endemic_specie == "ee_si" ~ "SI",
                                                    !(endemic_specie == "ee_no") | !(endemic_specie == "ee_no") ~ "-"),
                  endemic_subspecie = dplyr::case_when(endemic_subspecie == "es_no" ~ "NO",
                                                       endemic_subspecie == "es_si" ~ "SI",
                                                       !(endemic_subspecie == "es_no") | !(endemic_subspecie == "es_no") ~ "-"),
                  origin = dplyr::case_when(origin == "ns" ~ "Nativo seguro", origin == "np" ~ "Nativo probable", 
                                            origin == "isi" ~ "Introducido seguro invasor", origin == "isn" ~ "Introducido seguro no invasor", 
                                            origin == "ip" ~ "Introducido probable"),
                  category = dplyr::case_when(category == "ep" ~ "Especie protegida",
                                              category == "ei" ~ "Especie introducida",
                                              !(endemic_subspecie == "ep") | !(endemic_subspecie == "ei") ~ "-"),    
                  author = stringr::str_replace_all(author, t_replacement)) |> 
    dplyr::inner_join(data_biota, ., by="id_biota") |> 
    dplyr::select(-subdivision, division) |> 
    readr::write_tsv("data/coord_plantae.tsv")
