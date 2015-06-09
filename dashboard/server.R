library(shiny)
library(shinydashboard)

library(streamgraph)
packageVersion("streamgraph")
library(dplyr)

source("../tmscript.R")
load("../data/docs.file")

test <- function(test){
  print("test")
  print(test)
}


renderLDAvis <- function(){
  print("renderLDAvis")
    # create dtm
  dtm <-createDTM(
    docs,
    list(
      tolower = TRUE,
      removePunctuation = TRUE,
      removeNumbers = TRUE,
      stopwords = stopwords("de"),
      stemming = TRUE,
      weighting = weightTf
    ), 
    sparsity = 0.99
  )
  
  # create models
  models <- getModels(
    dtm,
    burnin = 1,
    iter = 1,
    keep = 50,
    ks = seq(20, 28, by = 1),
    sel.method = "Gibbs"  
  )
  
  # select best model and create json
  bestModel <- getBestModel(
    models,
    burnin = 1, 
    keep = 50,
    ks = seq(20, 28, by=1)
  )
  
  unlink("eyes_lda", recursive = TRUE, force = FALSE)
  json <- getJSON(bestModel)
  serVis(json, out.dir="eyes_lda", open.browser = FALSE)
  
}


shinyServer(
  function(input, output){
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
)
