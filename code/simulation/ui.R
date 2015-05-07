library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Umverteilungswirkung der Erbschaftssteuer"),
  
  tags$p("Wir gehen von der Verteilung der Vermögen in Bern 2012 aus und nehmen an, dass im Erbfall alle Vermögen oberhalb von 2 Mio. CHF zu 20% versteuert werden und diese Steuereinnahmen gleichmässig auf die gesamte Bevölkerung verteilt werden. Der Rest der Verteilung wird als fix über die Zeit angenommen."),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("jahre",
                  "Vermögensverteilung nach 0 bis 1000 Jahren:",
                  min = 0,
                  max = 1000,
                  value = 50)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
))