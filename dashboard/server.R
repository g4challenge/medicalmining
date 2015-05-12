library(shiny)
library(shinydashboard)
library(streamgraph)
library(dplyr)
packageVersion("streamgraph")
library(dplyr)

test <- function(i){
  print("test")
  print(i)
}

server <- function(input, output, session){
  
  
  output$value <- renderPrint({ 
    input$text
    print("test")
    
  })
  
  output$testhtml <- renderUI({
    
    #    source("../tmscriptFacade.R")
    
    addResourcePath("library", "../data/eyes_lda")    
    tags$iframe(src="library/index.html", width=1300, height=800)
  })
  

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
    
}