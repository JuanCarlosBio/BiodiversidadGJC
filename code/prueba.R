## El visor que planteo en el futuro
library(leaflet)

# Create a Leaflet map of Gran Canaria
gran_canaria_map <- leaflet() %>%
  setView(-15.6, 27.95, zoom = 11) %>%
  addTiles()

gran_canaria_map
