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
  ggplot2::movies %>%
    select(year, Action, Animation, Comedy, Drama, Documentary, Romance, Short) %>%
    tidyr::gather(genre, value, -year) %>%
    group_by(year, genre) %>%
    tally(wt=value) %>%
    ungroup %>%
    streamgraph("genre", "n", "year") %>%
    sg_axis_x(20) %>%
    sg_fill_brewer("PuOr") %>%
    sg_legend(show=TRUE, label="Genres: ") -> sg
  
  output$sg1 <- renderStreamgraph(sg)
  
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