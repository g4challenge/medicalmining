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
             checkboxInput("toLower", label = "To Lower", value = FALSE),
             checkboxInput("punctuation", label = "Remove Punctuation", value = FALSE),
             checkboxInput("numbers", label = "Remove Number", value = FALSE),
             checkboxInput("stemming", label = "Stemming", value = FALSE),
             sliderInput("waitingRate", "Waiting ...", min = 0, max = 50, value = 1, step = 0.5),
             textInput("stopwords", label = "Stopwords"),
             sliderInput("sparsity", "Sparsity ...", min = 0, max = 10, value = 1, step = 2)
    ), 
    menuItem("Model Controll", tabName = "Model", icon = icon("cog", lib = "glyphicon"),
             numericInput("burning", label = "Burning", value = 1),
             numericInput("iterator", label = "Iterator", value = 1),
             numericInput("keep", label = "Keep", value = 1),  
             sliderInput("ks", label = "ks-Range", min = 0, max = 100, value = c(40, 60))           
    )
    
  )
)



# main body
body <- dashboardBody(
  fluidRow(
    tags$iframe(
      src="file:///Users/lukas/ownCloud/documents/topicModelNetDoktor/eyes_lda/index.html#topic=0&lambda=1&term="),
    plotOutput('plot', width = "300px", height = "300px")
  ),
  fluidRow(
    # A static valueBox
    valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
    
    # Dynamic valueBoxes
    valueBoxOutput("progressBox"),
    
    valueBoxOutput("approvalBox")
  ),
  fluidRow(
    # Clicking this will increment the progress amount
    box(width = 4, actionButton("count", "Increment progress"))
  )
)







ui <- dashboardPage(skin = "black", header, sidebar, body)
