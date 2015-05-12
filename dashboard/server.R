library(shiny)
library(shinydashboard)

test <- function(i){
  print("test")
  print(i)
}

server <- function(input, output, session){  
  output$testhtml <- renderUI({
    
    #    source("../tmscriptFacade.R")
    
    addResourcePath("library", "../data/eyes_lda")    
    tags$iframe(src="library/index.html", width=1300, height=800)
  })
  
  
}