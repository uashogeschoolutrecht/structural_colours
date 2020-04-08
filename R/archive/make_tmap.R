library(sf)
library(spData)
library(tmap)
#install.packages("mapview")
#library(mapview)

#X = lon, Y = lat, two separate columns
path = "/home/rstudio/scpackage/inst/extdata/MGYS00000974.csv"
data = st_read(path, options = c("X_POSSIBLE_NAMES=X","Y_POSSIBLE_NAMES=Y")) #https://gdal.org/drivers/vector/csv.html

data$geometry
#note: no crs defined

#trying most popular crs, epsg = 4326
st_crs(data) = 4326
data$geometry
world$geom #also in 4326
plot(world$geom, reset=FALSE)
plot(data$geometry, add=TRUE, col="red") #seems accurate! is also defined in MIxS as the crs that has to be used

st_is_longlat(data) #TRUE

st_buffer(data, dist = 1) #some (distance related) functions require projected data (is now geographic data)

#saving plot
system("mkdir /home/rstudio/scpackage/inst/images/")
png(filename = "/home/rstudio/scpackage/inst/images/sample_points.png", width = 500, height = 350)
plot(world$geom, reset=FALSE)
plot(data$geometry, add=TRUE, col="red")
dev.off()

#mapview_obj = mapview(world, zcol = "lifeExp", legend = TRUE)
#mapshot(mapview_obj, file = "my_interactive_map.html")

world_samples <- tm_shape(world) +
  tm_polygons() +
  tm_shape(data) +
  tm_symbols(shape = 1, col = "red", size = 1)
tmap_mode("view")

usethis::use_data(world_samples)
