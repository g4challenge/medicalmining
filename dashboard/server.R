library(shiny)
library(shinydashboard)

library(streamgraph)
packageVersion("streamgraph")

library(dplyr)

addResourcePath("lda_lib", "../data/eyes_lda")    
#source("../tmscriptFacade.R")
load("../data/docs.file")


test <- function(i){
  print("test")
  print(i)
}

server <- function(input, output, session){
  df = getPostsAsCSV()
  df %>%
    streamgraph("topic", "size", "date") %>%
    sg_axis_x(1, "date", "%Y") %>%
    sg_colors("PuOr")%>%
    sg_legend(show=TRUE, label="Topic: ") -> sg
  
  output$sg <- renderStreamgraph(sg)
  
  output$test <- renderPrint(
    list(
      # dtm
      toLower = input$toLower,
      punctuation = input$punctuation,
      numbers = input$numbers,
      stemming = input$stemming,      
      weighting = input$weighting,
      
      stopwords = input$stopwords,
      words = input$words,
      
      # list of all real stopword whicht shoud be used
      realstopwords = setdiff(append(stopwords("de"), input$words), input$stopwords),

      sparsity = input$sparsity,
      
      # model
      burning = input$burning,
      iterator = input$iterator,
      keep = input$keep,
      ks = input$ks
      
      )
  )
}