library(shiny)
library(shinydashboard)

library(streamgraph)
packageVersion("streamgraph")
library(dplyr)

addResourcePath("lda_lib", "../data/eyes_lda")    
source("../tmscript.R")
load("../data/docs.file")

server <- function(input, output, session){
  df = getPostsAsCSV()
  df %>%
    streamgraph("topic", "size", "date") %>%
    sg_axis_x(1, "date", "%Y") %>%
    sg_colors("PuOr")%>%
    sg_legend(show=TRUE, label="Topic: ") -> sg
  output$sg <- renderStreamgraph(sg)
  
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