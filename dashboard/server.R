library(shiny)
library(shinydashboard)

#library(streamgraph)
#packageVersion("streamgraph")
#library(dplyr)

#source("../tmscript.R")
#load("../data/docs.file")

test <- function(test){
  print(test)
}

server <- function(input, output, session) {
  
  output$results = renderPrint({
    input$mydata
  })
  
  observe({
    input$mydata
    stopword = input$mydata
    session$sendCustomMessage(type = "myCallbackHandler", stopword)
  })
  
  observe({
    if (input$renderLDAvis > 0) {
      test("start spinner")

      
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "Making new LDAVis Model", value = 0)
      
      n <- 6
      
      # create dtm
      i <- 1
      progress$inc(1/n, detail = paste("Doing part", i))
      dtm <- createDTM(
        docs,
        list(
          tolower = input$toLower,
          removePunctuation = input$punctuation,
          removeNumbers = input$numbers,
          stopwords = setdiff(append(stopwords("de"), input$words), input$stopwords),
          stemming = input$stemming,
          weighting = weightTf
        ), 
        sparsity = input$sparsity
      )
      
            
      # create models
      i <- i + 1
      progress$inc(1/n, detail = paste("Doing part", i))
      models <- getModels(
        dtm,
        burnin = input$burning,
        iter = input$iterator,
        keep = input$keep,
        ks = seq(20, 28, by = 1),
        sel.method = "Gibbs"  
      )
      
            
      
      # select best model and create json
      i <- i + 1
      progress$inc(1/n, detail = paste("Doing part", i))
      bestModel <- getBestModel(
        models,
        burnin=input$burning, 
        keep=input$keep,
        ks = seq(20, 28, by=1)
      )
      
      
      # remove folder
      i <- i + 1
      progress$inc(1/n, detail = paste("Doing part", i))
      #unlink("../data/eyes_lda", recursive = TRUE, force = FALSE)
      
      
      # generate json
      i <- i + 1
      progress$inc(1/n, detail = paste("Doing part", i))
      json <- getJSON(bestModel)
      
      
      # serVis
      i <- i + 1
      progress$inc(1/n, detail = paste("Doing part", i))
      #TODO umbauen
      #TODO javascript editieren
      #serVis(json, out.dir="../data/eyes_lda", open.browser = FALSE)
      write(json, "eyes_lda/lda.json")
      test("end spinner")
    }
  })
  
#   df = getPostsAsCSV()
#   df %>%
#     streamgraph("topic", "size", "date") %>%
#     sg_axis_x(1, "date", "%Y") %>%
#     sg_colors("PuOr")%>%
#     sg_legend(show=TRUE, label="Topic: ") -> sg
#   
#   output$sg <- renderStreamgraph(sg)
  
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
