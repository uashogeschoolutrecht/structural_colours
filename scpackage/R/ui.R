library(shiny)
library(shinydashboard)
library(shinyWidgets)

path = "/home/rstudio/scpackage/inst/extdata/MGYS00000974.csv"
path2 = "/home/rstudio/scpackage/inst/extdata/MGYS00000991_clean.csv"
path3 = "/home/rstudio/scpackage/inst/extdata/MGYS00005036.csv"

data = st_read(path, options = c("X_POSSIBLE_NAMES=X", "Y_POSSIBLE_NAMES=Y")) #https://gdal.org/drivers/vector/csv.html
data2 = st_read(path2, options = c("X_POSSIBLE_NAMES=X", "Y_POSSIBLE_NAMES=Y"))
data3 = st_read(path3, options = c("X_POSSIBLE_NAMES=X", "Y_POSSIBLE_NAMES=Y"))

st_crs(data) = 4326
st_crs(data2) = 4326
st_crs(data3) = 4326

shinyUI(fluidPage(sidebarLayout(
  sidebarPanel(h3("text")),
  mainPanel(tabsetPanel(
    tabPanel(
      "Map",
      leafletOutput('my_tmap'),
      absolutePanel(
        top = 470,
        right = 15,
        downloadButton('download_data', 'Download filtered dataset')
        ),
      h5("Filter the map using the sliders here."),
      absolutePanel(
        top = 510,
        right = 15,
        chooseSliderSkin("Nice"),
        sidebarPanel(
          width = '100%',
          sliderInput(
            "range",
            "Select the salinity range (parts per trillion)",
            min = min(as.numeric(data$salinity_ppt)),
            max = max(as.numeric(data$salinity_ppt)),
            step = 1,
            width = '300px',
            value = range(as.numeric(data$salinity_ppt))
          )
        )
      ),
      absolutePanel(
        top = 510,
        right = 365,
        chooseSliderSkin("Nice"),
        sidebarPanel(
          width = '100%',
          sliderInput(
            "range2",
            "Select the depth range (meters)",
            min = min(as.numeric(data$depth_m)),
            max = max(as.numeric(data$depth_m)),
            step = 0.1,
            width = '300px',
            value = range(as.numeric(data$depth_m))
          )
        )
      )

    ),
    tabPanel(
      "Map data",
      dataTableOutput("map_table")
    ),
    tabPanel(
      "Krona plot",
      tags$iframe(style = "height: 750px; width: 100%",
                  srcdoc = HTML(as.character(
                    includeHTML("/home/rstudio/data/text.krona.html")
                  )))
    ),
    tabPanel(
      "Bin blobs",
      fileInput("covstats_file", "Upload covstats file here."),
      fileInput("taxonomy_file", "Upload taxonomy file here."),
      selectInput("taxon_level", "Select taxonomy level", choices = c("Superkingdom",
                                                                      "Phylum",
                                                                      "Class",
                                                                      "Order",
                                                                      "Family",
                                                                      "Genus",
                                                                      "Species")),
      #plot here
      plotOutput("bin_plot")

    )
  ))
)))
