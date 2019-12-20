library(shiny)
library(shinydashboard)

#setwd("/home/$USER/scpackage/R")

shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      h5("Blalalal")
    ),
    mainPanel(tabsetPanel(
      tabPanel("Map",
               leafletOutput('my_tmap'),

    ),
    tabPanel("Krona plot",
             tags$iframe(style="height: 800px; width: 100%",
                         srcdoc=HTML(as.character(includeHTML("/home/rstudio/data/text.krona.html")))))
    ))
)))



# shinyUI(dashboardPage(
#   dashboardHeader(title = "Metagenome samples and metadata"),
#   dashboardSidebar(),
#   dashboardBody(
#     tabItems(
#       tabItem(tabName = "Map",
#               fluidRow(
#                 box(plotOutput('my_tmap', height = 200))
#               ),
#               box(
#                 title = "Controls",
#                 sliderInput("slider", "Number of observations:", 1, 100, 50)
#               ))
#     #   ,
#     #   tabItem(tabName = "Krona taxonomy",
#     #           fluidRow(
#     #             box(HTML(as.character(includeHTML("/home/rstudio/data/text.krona.html"))
#     #           ))
#     # )
#     # )
# )
# )
# )
# )
#
#
# #  sidebarLayout(
# #    sidebarPanel(h3("Side bar panel"), h4("Extra text")),
# #    mainPanel(navlistPanel(
# #                tabPanel("Map", leafletOutput("my_tmap")),
# #                tabPanel("Krona", HTML(as.character(includeHTML("/home/rstudio/data/text.krona.html"))))
# #              )
# #
# #  )
# #)))
#
