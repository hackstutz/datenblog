library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Umverteilungswirkung der Erbschaftssteuer"),
  
  tags$p("Wir gehen von der Verteilung der Reinvermögen (Total der Vermögen minus Schulden) in Bern 2012 aus und nehmen an, dass alle vererbten Vermögen oberhalb von 2 Mio. CHF und Schenkungen von mehr als 20.000 CHF zu 20% versteuert werden und diese Steuereinnahmen gleichmässig auf die gesamte Bevölkerung verteilt werden."),
  tags$p("Der Rest der Verteilung wird als fix über die Zeit angenommen. Da in den Daten nur die Empfängerseite der Erbschaften dokumentiert ist, die Steuer jedoch auf den Erblass erhoben wird, gehen wir davon aus, dass für erhaltene Erbschaften grösser 1 Mio. CHF gilt, dass der Erblass grösser als 2 Mio. CHF ist und die Steuer approximativ ab dieser Grenze anfallen würde."),
  tags$p("Bezüglich der Umverteilungsgeschwindigkeit wird angenommen, dass durchschnittlich nach 60 Jahren alles vererbbare (rote Fläche in der Grafik) ein mal besteuert wurde. Die Annahme leitet sich ab aus dem Verhältnis der vererbten plus verschenkten Reinvermögen 2012 zu den Reinvermögen grösser 1 Mio. CHF (steuerbare Reinvermögen) ab."),
  tags$p("Mit dem Schiebebalken können Sie simulieren, wie sich die potentiell verteilbaren Vermögen (rot) innerhalb von 0 bis 1000 Jahren auf die Bevölkerung (blau) umverteilen."),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("jahre",
                  "Vermögensverteilung nach 0 bis 1000 Jahren:",
                  min = 0,
                  max = 1000,
                  value = 60),
    sliderInput("steuersatz",
                "bei einem Steuersatz von 0 bis 100%:",
                min = 0,
                max = 100,
                value = 20)
  ),
  # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot",width="100%")
    )
  )
))