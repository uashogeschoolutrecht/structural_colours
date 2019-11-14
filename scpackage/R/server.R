library(shiny)
library(sf)
library(spData)
library(tmap)
library(leaflet)
#library(KronaR)
#devtools::install_git("https://github.com/pierreLec/KronaR")


#creating map to plot
path = "/home/rstudio/scpackage/inst/extdata/MGYS00000974.csv"
path2 = "/home/rstudio/scpackage/inst/extdata/MGYS00000991_clean.csv"
path3 = "/home/rstudio/scpackage/inst/extdata/MGYS00005036.csv"

data = st_read(path, options = c("X_POSSIBLE_NAMES=X","Y_POSSIBLE_NAMES=Y")) #https://gdal.org/drivers/vector/csv.html
data2 = st_read(path2, options = c("X_POSSIBLE_NAMES=X","Y_POSSIBLE_NAMES=Y"))
data3 = st_read(path3, options = c("X_POSSIBLE_NAMES=X","Y_POSSIBLE_NAMES=Y"))

st_crs(data) = 4326
st_crs(data2) = 4326
st_crs(data3) = 4326

shinyServer(
  function(input, output) {
    tm = tm_shape(world) +
      tm_polygons() +
      tm_shape(data) +
      tm_dots(shape = 1, col = "red", size = 0.01) +
      tm_shape(data2) +
      tm_dots(shape = 1, col = "blue", size = 0.01) +
      tm_shape(data3) +
      tm_dots(shape = 1, col = "yellow", size = 0.01)
    tm = tmap_leaflet(tm)
    output$my_tmap = renderLeaflet({
      tm
    }
    )
  }
)
