library(shiny)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  
  plotDist <- function(quintile, erbsubstanz, jahre,steuersatz) {
    summe <- sum(c(-5.18e+09,4.28e+08,3.65e+09,1.61e+10,1.23e+11))
    freibetragszenario <- reactive({
      dataset <- input$file1$datapath
    })
    freibetragszenarien <- c("500k"=7.044e+10,"1M"=5.044e+10,"2M"=3.558e+10,"10M"=1.587e+10)
    freibetragszenario <- reactive({
      switch(input$freibetragszenario,
             "500k" = 1,
             "1M" = 2,
             "2M" = 3,
             "10M" = 4)
    })
    erbsubstanz <- c(0,0,0,0,freibetragszenarien[freibetragszenario()])/summe # Summe der Reinvermögen die über 2Mio pro Steuereinheit hinaus gehen.
    quintile <- c(-5.18e+09,4.28e+08,3.65e+09,1.61e+10,1.23e+11)/summe-erbsubstanz # Quintile aus den Daten Bern 2012, Reinvermögen
    
    exponent <- floor(1:jahre/60.0000001)
    abzug <- sum((1-steuersatz)^exponent * 1/60*steuersatz)
    erbsubstanz_neu <- erbsubstanz-erbsubstanz*abzug #annahme, dass nach 60 Jahren alles vererbt wurde. Die Annahme leitet sich ab aus dem Verhältnis der vererbten+verschenkten Reinvermögen 2012 zu den Reinvermögen > 1 Mio CHF (steuerbare Reinvermögen)
    verteiltemasse <- (sum(erbsubstanz)-sum(erbsubstanz_neu)) # teil vom kuchen der zu verteilen ist
    umverteilt <- rep(verteiltemasse/5,5) # umverteilung auf alle. 
    umverteilt[5] <- umverteilt[5]*(erbsubstanz_neu[5]/erbsubstanz[5])# korrektur des letzten quintils (q5 bekommt zwar etwas, muss das in den folgejahren aber wieder versteuern)
    labs <- seq(0,1,0.2)
    barplot(rbind(quintile,erbsubstanz_neu,umverteilt),ylim=c(-0.15,1),col=c("#1a476f","#a0353b","#55952f"),legend.text = c("Reinvermögen unter Freibetrag", "Umverteilbare Vermögen\n(Reinvermögen über Freibetrag)","Umverteilte Vermögen"),args.legend = list(x = "topleft"),axes = FALSE,axisnames=FALSE,xlab="Vermögensquintile",ylab="Anteil am Gesamtvermögen")
    axis(side = 2, at = labs, labels = paste0(labs * 100, "%"), cex.axis = 1)
    axis(side = 1, at = seq(0.7,6,1.2), labels = paste0("Q",1:5), cex.axis = 1)
    abline(h=0)
    }
  
  
  output$distPlot <- renderPlot({
    plotDist(quintile,erbsubstanz,jahre=input$jahre,steuersatz=input$steuersatz/100)
  })
  
})