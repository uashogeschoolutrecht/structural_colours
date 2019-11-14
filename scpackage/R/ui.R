library(shiny)
#setwd("/home/$USER/scpackage/R")

shinyUI(fluidPage(
  titlePanel(title = "Metagenome samples and metadata"),
  sidebarLayout(position = "right",
                sidebarPanel(h3("Side bar panel"), h4("Extra text"), renderPlot("test")),
                mainPanel("Main panel",leafletOutput("my_tmap"))
  )
)


)

