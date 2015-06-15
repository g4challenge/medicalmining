library(shiny)
library(shinydashboard)

library(streamgraph)
packageVersion("streamgraph")
library(dplyr)

source("../tmscript.R")
source("../tmscriptFacade.R")
load("../data/docs.file")

test <- function(test){
  print(test)
}

shinyServer(function(input, output, session) {
  observe({
    if (input$renderLDAvis > 0) {
      test("start spinner")
      tmsciptFasade(
        tolower__ = input$toLower,
        removePunctuation__ = input$punctuation,
        removeNumbers__ = input$numbers,
        stopwords__ = setdiff(append(stopwords("de"), input$words), input$stopwords),
        stemming__ = input$stemming,
        sparsity__ = input$sparsity,
        burnin__ = input$burning,
        iter__ = input$iterator,
        keep__ = input$keep
      )      
      test("end spinner")
    }
  })
  
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
})
