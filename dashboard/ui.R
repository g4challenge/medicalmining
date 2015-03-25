## ui.R ##

library(shinydashboard)

header <-  dashboardHeader(title = "MeMi", 
                           dropdownMenuOutput("messageMenu"),
                           dropdownMenuOutput("notificationMenu"),
                           dropdownMenuOutput("taskMenu")
)

sidebar <- dashboardSidebar(
  sidebarSearchForm(textId = "searchText", buttonId = "searchButton",
                    label = "Search..."),
  sidebarMenu(
  menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
  menuItem("Widgets", icon = icon("th"), tabName = "widgets",
           badgeLabel = "new", badgeColor = "green")
)
)
body <- dashboardBody(
  fluidRow(
  tags$iframe(
    src="file:///Users/lukas/ownCloud/documents/topicModelNetDoktor/eyes_lda/index.html#topic=0&lambda=1&term="),
  plotOutput('plot', width = "300px", height = "300px")
  ),
  fluidRow(
    # A static valueBox
    valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
    
    # Dynamic valueBoxes
    valueBoxOutput("progressBox"),
    
    valueBoxOutput("approvalBox")
  ),
  fluidRow(
    # Clicking this will increment the progress amount
    box(width = 4, actionButton("count", "Increment progress"))
  )
)


ui <- dashboardPage(header, sidebar, body)
