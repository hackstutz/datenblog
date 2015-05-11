library(shiny)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  summe <- sum(c(-5.18e+09,4.28e+08,3.65e+09,1.61e+10,1.23e+11))
  erbsubstanz <- c(0,0,0,0,5.044e+10)/summe # Summe der Reinvermögen die über 1Mio pro Steuereinheit hinaus gehen.
  quintile <- c(-5.18e+09,4.28e+08,3.65e+09,1.61e+10,1.23e+11)/summe-erbsubstanz # Quintile aus den Daten Bern 2012, Reinvermögen
  
  
  plotDist <- function(quintile, erbsubstanz, jahre,steuersatz) {
    exponent <- floor(1:jahre/60.0000001)
    abzug <- sum((1-steuersatz)^exponent * 1/60*steuersatz)
    erbsubstanz_neu <- erbsubstanz-1.25*erbsubstanz*abzug #annahme, dass nach 60 Jahren alles vererbt wurde. Die Annahme leitet sich ab aus dem Verhältnis der vererbten+verschenkten Reinvermögen 2012 zu den Reinvermögen > 1 Mio CHF (steuerbare Reinvermögen)
    erbsubstanz_neu <- erbsubstanz_neu + (sum(erbsubstanz)-sum(erbsubstanz_neu))/5 # gleichmässige umverteilung auf alle leute
    quintile <- quintile+erbsubstanz_neu/5
    labs <- seq(0,1,0.2)
    barplot(rbind(quintile,erbsubstanz_neu),ylim=c(-0.15,1),col=c("#1a476f","#90353b"),legend.text = c("Reinvermögen <= 2 Mio. CHF", "Umverteilbare Vermögen\n(Reinvermögen > 2 Mio. CHF)"),args.legend = list(x = "topleft"),axes = FALSE,xlab="Vermögensquintile",ylab="Anteil am Gesamtvermögen")
    axis(side = 2, at = labs, labels = paste0(labs * 100, "%"), cex.axis = 1)
    axis(side = 1, at = seq(0.7,6,1.2), labels = paste0("Q",1:5), cex.axis = 1)
    abline(h=0)
    }
  
  
  output$distPlot <- renderPlot({
    plotDist(quintile,erbsubstanz,jahre=input$jahre,steuersatz=input$steuersatz/100)
  })
  
})