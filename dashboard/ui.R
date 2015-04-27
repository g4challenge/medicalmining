## ui.R ##
library(shinydashboard)

# header
header <-  dashboardHeader(title = "MeMi", 
                           dropdownMenuOutput("messageMenu"),
                           dropdownMenuOutput("notificationMenu"),
                           dropdownMenuOutput("taskMenu")
)

# sidebar
sidebar <- dashboardSidebar(
  sidebarSearchForm(textId = "searchText", buttonId = "searchButton",
                    label = "Search..."),
  sidebarMenu(
    menuItem("dtm Controll", tabName = "dtm",  icon = icon("cog", lib = "glyphicon"),
             checkboxInput("toLower", label = "To Lower", value = TRUE),
             checkboxInput("punctuation", label = "Remove Punctuation", value = TRUE),
             checkboxInput("numbers", label = "Remove Number", value = TRUE),
             checkboxInput("stemming", label = "Stemming", value = TRUE),
             checkboxInput("weighting", label = "Weighting", value = TRUE),
             textInput("stopwords", label = "Stopwords"),
             sliderInput("sparsity", "Sparsity ...", min = 0.0, max = 1, value = 0.99, step = 0.01)
    ), 
    menuItem("Model Controll", tabName = "Model", icon = icon("cog", lib = "glyphicon"),
             numericInput("burning", label = "Burning", value = 100),
             numericInput("iterator", label = "Iterator", value = 100),
             numericInput("keep", label = "Keep", value = 50),  
             sliderInput("ks", label = "ks-Range", min = 0, max = 100, value = c(20, 80))           
    )
  )
)

# main body
body <- dashboardBody(
  fluidRow(
    box(
      title = "Diagram", solidHeader = TRUE, width = "620px",
      plotOutput('plot', width = "600px", height = "600px")
    )
  ),
  fluidRow(
    box(
      title = "Inputs", solidHeader = TRUE,
      width = 4, 
      actionButton("goPlot", "Render")
    )
  )
)



ui <- dashboardPage(skin = "black", header, sidebar, body)
