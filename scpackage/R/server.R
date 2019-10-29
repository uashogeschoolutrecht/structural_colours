library(shiny)
library(sf)
library(spData)
library(tmap)

shinyServer(
  function(input, output) {
    tm = tm_shape(world) + tm_polygons()
    tm = tmap_leaflet(tm)
    output$my_tmap = renderLeaflet({
      tm
    }
    )
  }
)