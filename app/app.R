library(shiny)

# Load UI and server components
source("global.R")
source("ui.R")
source("server.R")

# Launch the app
shinyApp(ui = ui, server = server)
 