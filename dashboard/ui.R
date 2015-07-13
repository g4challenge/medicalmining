## ui.R ##
library(shinydashboard)
library(streamgraph)

#source("../memiMongo.R")
source("../tmscriptFacade.R")
addResourcePath("lda_lib", "eyes_lda/")

# header
header <-  dashboardHeader(
  title = "MeMi",
  dropdownMenuOutput("messageMenu"),
  dropdownMenuOutput("notificationMenu"),
  dropdownMenuOutput("taskMenu")
)

# sidebar
sidebar <- dashboardSidebar(
  sidebarSearchForm(
    textId = "searchText", buttonId = "searchButton",
    label = "Search..."
  ),
  sidebarMenu(
    menuItem("LDAvis", tabName = "ldavis"),
    menuItem("Debug", tabName = "testtab"),
    menuItem("Streamgraph Data", tabName = "streamgraph"),
    
    menuItem(
      "dtm Controll", tabName = "dtm",  icon = icon("cog", lib = "glyphicon"),
      
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
    ),
    menuItem(
      "Model Controll", tabName = "Model", icon = icon("cog", lib = "glyphicon"),
      numericInput("burning", label = "Burning", value = 1),
      numericInput("iterator", label = "Iterator", value = 1),
      numericInput("keep", label = "Keep", value = 50),
      
      selectInput(
        "ksFixpointRange", "Choose ks-input Method:", choices = c('Fixpoint' = '1','Range' =
                                                                    '2')
      ),
      
      sliderInput(
        "ksrange", label = "ks-Range", min = 0, max = 100, value = c(20, 80)
      ),
      numericInput(
        "ksfix", label = "ks-fix", value = 20, min = 2, max = 2000
      )
    ),
    menuItem(actionButton("renderLDAvis", "Generate LDAvis"))
  )
)

# main body
body <- dashboardBody(
  includeScript("www/d3.v3.js"),
  includeScript("www/ldavis.js"),
  mainPanel(tabItems(
    tabItem("testtab",
            verbatimTextOutput('test')),
    tabItem("streamgraph",
            streamgraphOutput('sg')),
    tabItem(
      "ldavis",
      includeCSS("www/lda.css"),
      tags$script(
        "var vis = new LDAvis('#lda', 'lda_lib/lda.json');"
      ),
      tags$script("
                  Shiny.addCustomMessageHandler('myCallbackHandler',
                  function(stopword) {
                  var selectize = $('select')[1].selectize;
                  selectize.addItem(stopword, false);
                  });
                  "),
      verbatimTextOutput("results"),
      tags$div(id = "lda")
      )
  ), width = 12))

ui <- dashboardPage(skin = "black", header, sidebar, body)
