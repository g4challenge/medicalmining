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
    menuItemOutput("dtmControl"),
    menuItemOutput("modelControl"),
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
