library(shiny)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  summe <- sum(c(-5.41e+08,1.07e+09,6.75e+09,3.61e+10,1.67e+11))
  erbsubstanz <- c(0,0,0,0,4.721e+10)/summe # Summe der Vermögen die über 2Mio pro Steuereinheit hinaus gehen.
  quintile <- c(-5.41e+08,1.07e+09,6.75e+09,3.61e+10,1.67e+11)/summe-erbsubstanz # Quintile aus den Daten Bern 2012
  
  
  plotDist <- function(quintile, erbsubstanz, jahre) {
    erbsubstanz_neu <- erbsubstanz*(0.8^((jahre+1)/80)) #annahme, dass nach 80 Jahren alles vererbt wurde
    erbsubstanz_neu <- erbsubstanz_neu + (sum(erbsubstanz)-sum(erbsubstanz_neu))/5 # gleichmässige umverteilung auf alle leute
    quintile <- quintile+erbsubstanz_neu/5
    barplot(rbind(quintile,erbsubstanz_neu),ylim=c(0,1))
    }
  
  
  output$distPlot <- renderPlot({
    plotDist(quintile,erbsubstanz,jahre=input$jahre)
  })
  
})