# library(shiny)
# library(sf)
# library(spData)
# library(tmap)
# library(leaflet)
# source("/home/rstudio/scpackage/R/gbtools.R")
#
# #creating map to plot
# path = "/home/rstudio/scpackage/inst/extdata/MGYS00000974.csv"
# path2 = "/home/rstudio/scpackage/inst/extdata/MGYS00000991_clean.csv"
# path3 = "/home/rstudio/scpackage/inst/extdata/MGYS00005036.csv"
#
# data = st_read(path, options = c("X_POSSIBLE_NAMES=X", "Y_POSSIBLE_NAMES=Y")) #https://gdal.org/drivers/vector/csv.html
# data2 = st_read(path2, options = c("X_POSSIBLE_NAMES=X", "Y_POSSIBLE_NAMES=Y"))
# data3 = st_read(path3, options = c("X_POSSIBLE_NAMES=X", "Y_POSSIBLE_NAMES=Y"))
#
# st_crs(data) = 4326
# st_crs(data2) = 4326
# st_crs(data3) = 4326
#
# data$salinity_ppt = as.numeric(data$salinity_ppt)
# data$depth_m = as.numeric(data$depth_m)
#
# shinyServer(function(input, output) {
#   filtered = reactive({
#     data[data$salinity_ppt >= input$range[1] & data$salinity_ppt <= input$range[2] #filter for salinity slider
#          & data$depth_m >= input$range2[1] & data$depth_m <= input$range2[2], ] #filter for depth slider
#   })
#   output$my_tmap = renderLeaflet({
#     leaflet(data = data) %>%
#       addTiles(group = "OSM") %>%
#       addProviderTiles("Esri.WorldImagery", group = "Esri") %>%
#       hideGroup("Markers")
#   })
#
#   output$bin_plot = renderPlot({
#     in_covstats <- input$covstats_file
#     in_taxonomy <- input$taxonomy_file
#     if (is.null(in_covstats) | is.null(in_taxonomy)) return(NULL)
#
#     path_covstats = in_covstats$datapath
#     path_taxonomy = in_taxonomy$datapath
#
#     gbtools_plot(covstats_datapath = path_covstats,
#                  taxonomy_datapath = path_taxonomy,
#                  colour_tax_level = input$taxon_level)
#     })
#
#   output$map_table = renderDataTable(filtered() %>%
#                                   as.data.frame())
#   output$download_data <- downloadHandler(
#       filename = function() {
#         paste('data-', Sys.Date(), '.csv', sep='')
#       },
#       content = function(con) {
#         write.csv(data[data$salinity_ppt >= input$range[1] & data$salinity_ppt <= input$range[2]
#                        & data$depth_m >= input$range2[1] & data$depth_m <= input$range2[2], ], con)
#       }
#     )
#   observe(
#     leafletProxy("my_tmap", data = filtered()) %>%
#       clearMarkers() %>%
#       addMarkers(
#         lng = ~ X,
#         lat = ~ Y,
#         group = "Markers",
#         popup = ~ paste0(
#           "sample ID: ", accession, "<br>",
#           "platform: ", instrument_model, "<br>",
#           "depth (m): ", depth_m, "<br>",
#           "salinity (ppt): ", salinity_ppt, "<br>",
#           "description (max 100 char.): ", paste0(substr(sample.desc, start = 1, stop = 100), "...")
#         )
#       ) %>%
#       addCircleMarkers(
#         lng = ~ X,
#         lat = ~ Y,
#         group = "Circle Markers",
#         popup = ~ paste0(
#           "sample ID: ", accession, "<br>",
#           "platform: ", instrument_model, "<br>",
#           "depth (m): ", depth_m, "<br>",
#           "salinity (ppt): ", salinity_ppt, "<br>",
#           "description (max 100 char.): ", paste0(substr(sample.desc, start = 1, stop = 100), "...")
#         )
#       ) %>%
#       addLayersControl(
#         baseGroups = c("OSM", "Esri"),
#         overlayGroups = c("Markers", "Circle Markers"),
#         options = layersControlOptions(collapsed = FALSE)
#       )
#   )
# })
