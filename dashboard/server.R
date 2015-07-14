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

topicNcontrol <- 1

server <- function(input, output, session) {
  #Test javascript to shiny call
  output$results = renderPrint({
    input$mydata
  })
  
  #Test shiny to Frontend call
  observe({
    input$mydata
    stopword = input$mydata
    session$sendCustomMessage(type = "myCallbackHandler", stopword)
  })
  
  ## Build menu
  output$dtmControl <- renderMenu({
    menuItem(
      "dtm Control", tabName = "dtm",  icon = icon("cog", lib = "glyphicon"),
      
      checkboxInput("toLower", label = "To Lower", value = TRUE),
      checkboxInput("punctuation", label = "Remove Punctuation", value = TRUE),
      checkboxInput("numbers", label = "Remove Number", value = TRUE),
      checkboxInput("stemming", label = "Stemming", value = TRUE),
      checkboxInput("weighting", label = "Weighting", value = TRUE),
      
      selectInput(
        'stopwords', label = 'Remove stopwords', NULL, multiple = TRUE, selectize =
          TRUE
      ),
      selectInput(
        'words', label = 'Add stopword', dtm$dimnames$Terms, multiple = TRUE, selectize =
          TRUE
      ),
      
      sliderInput(
        "sparsity", "Sparsity ...", min = 0.0, max = 1, value = 0.99, step = 0.01
      )
    )
  })
  
  output$modelControl <- renderMenu({
    topicNcontrol <<- input$ksControl
    menuItem(
      "Model Control", tabName = "Model", icon = icon("cog", lib = "glyphicon"), selected = TRUE,
      selectInput('Type', label="Type TM", list("LDA", "CTM", "Pachinko"), multiple=F, selectize=TRUE),
      selectInput('Sampling', label="Sampling", list("VEM", "Gibbs"), multiple=F, selectize=TRUE),
      numericInput("burnin", label = "Burnin", value = 1),
      numericInput("iterator", label = "Iterator", value = 1),
      numericInput("keep", label = "Keep", value = 50),
      
      selectInput(
        "ksControl", "Choose ks-input Method:", choices = c('Fixpoint' = '1','Range' =
                                                              '2'),
        selected=topicNcontrol # wichtig um status zu erhalten!
      ),
      if(eval(!is.null(topicNcontrol) && topicNcontrol == 1)){
        numericInput("ksfix", label = "ks-fix", value = 20, min = 2, max = 2000)
      }
      else{
        sliderInput("ksrange", label = "ks-Range", min = 0, max = 100, value = c(20, 80))
      }
    )
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
      ksControl= input$ksControl,
      ks = input$ks
    )
  )
}
