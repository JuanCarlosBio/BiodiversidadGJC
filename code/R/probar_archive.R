library(archive)
library(tidyverse)
library(exifr)
library(jpeg)

names.files <- unzip("images/invertebrados.zip", list = TRUE)

files_df <- data.frame(name = names.files$Name, stringsAsFactors = FALSE) |>
    filter(!(str_detect(name, "NO CLASIFICADO")) & name != "/")

print(unzip("images/invertebrados.zip", files_df$name[1]))

files_df %>% 
    pull(name) %>%
    map_dfr(., ~read_exif(unzip("images/invertebrados.zip", .x)))

