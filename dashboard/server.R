library(shiny)
library(shinydashboard)
source("../tmscript.R")
load("../docs.file")

server <- function(input, output, session){
  output$messageMenu <- renderMenu({
    msgs <- list(messageItem(
      from = "Sales Dept",
      message = "Sales are steady this month."
    ),
    messageItem(
      from = "New User",
      message = "How do I register?",
      icon = icon("question"),
      time = "13:45"
    ),
    messageItem(
      from = "Support",
      message = "The new server is ready.",
      icon = icon("life-ring"),
      time = "2014-12-01")
    )
    
    dropdownMenu(type = "messages", .list= msgs)
    
  })
  
  output$notificationMenu <- renderMenu({
    notifications <- list(
      notificationItem(
        text = "5 new users today",
        icon("users")
      ),
      notificationItem(
        text = "12 items delivered",
        icon("truck"),
        status = "success"
      ),
      notificationItem(
        text = "Server load at 86%",
        icon = icon("exclamation-triangle"),
        status = "warning"
      )
    )    
    dropdownMenu(type = "notifications", .list=notifications)
  })
    
  output$taskMenu <- renderMenu({
    tasks <- list(
      taskItem(value = 90, color = "green",
               "Documentation"
      ),
      taskItem(value = 17, color = "aqua",
               "Project X"
      ),
      taskItem(value = 75, color = "yellow",
               "Server deployment"
      ),
      taskItem(value = 80, color = "red",
               "Overall project"
      )
    )
    dropdownMenu(type= "tasks", badgeStatus = "success", .list=tasks)
  })
  
  
  output$plot <- renderPlot({
    input$goPlot # Re-run when button is clicked
    
    withProgress(message = 'Creating plot', value = 0.1, {
      Sys.sleep(0.25)
      
      # Create 0-row data frame which will be used to store data
      dat <- data.frame(x = numeric(0), y = numeric(0))
      
      # withProgress calls can be nested, in which case the nested text appears
      # below, and a second bar is shown.
      withProgress(message = 'Generating data', detail = "part 0", value = 0, {
        for (i in 1:10) {
          # Each time through the loop, add another row of data. This a stand-in
          # for a long-running computation.
          dat <- rbind(dat, data.frame(x = rnorm(1), y = rnorm(1)))
          
          # Increment the progress bar, and update the detail text.
          incProgress(0.1, detail = paste("part", i))
          
          # Pause for 0.1 seconds to simulate a long computation.
          Sys.sleep(0.1)
        }
      })
      
      # Increment the top-level progress indicator
      incProgress(0.5)
      
      # Another nested progress indicator.
      # When value=NULL, progress text is displayed, but not a progress bar.
      withProgress(message = 'And this also', detail = "This other thing",
                   value = NULL, {
                     
                     Sys.sleep(0.75)
                   })
      
      # We could also increment the progress indicator like so:
      # incProgress(0.5)
      # but it's also possible to set the progress bar value directly to a
      # specific value:
      setProgress(1)
    })
    plot(dat)
  })
  
  addResourcePath("library", "../eyes_lda")
  output$testhtml <- renderUI({
  
    source("../test.R")
    
    
    tags$iframe(src="library/index.html", width=1024, height=768)
  })
  
}

