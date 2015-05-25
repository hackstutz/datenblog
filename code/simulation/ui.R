library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Umverteilungswirkung einer Erbschaftssteuer"),
  
  tags$p("Anhand untenstehender Grafik lässt sich die umverteilende Wirkung von unterschiedlich ausgestalteten Erbschaftssteuern simulieren. Ausgangspunkt ist die reale Vermögensverteilung der Berner Steuerhaushalte des Jahres 2012. Eingeteilt in fünf Gruppen (die 20% Ärmsten, die 20% Reichsten und die jeweils 20% dazwischen) sind die Anteile der jeweiligen Gruppen am Gesamtvermögen dargestellt. Blau eingefärbt sind die Vermögensteile unter dem Freibetrag, rot ist der Teil über dem Freibetrag, der von der Erbschaftssteuer tangiert ist. Besteuertes Vermögen wird vereinfachend auf alle Gruppen umverteilt. Dieser Teil ist grün eingefärbt. Die vereinfachten Annahmen der Simulation werden im Detail weiter unten beschrieben."),
  tags$p("Über den ersten Schiebebalken können Sie variieren, zu welchem Zeitpunkt (wieviele Jahre nach Einführung einer Erbschaftssteuer) Sie die Vermögensverteilung betrachten wollen. Der zweite Schiebebalken gibt Ihnen die Möglichkeit, die Auswirkung unterschiedlicher Steuersätze zu erkunden. Eine dritte Einstellung, die zur Simulation justiert werden kann, ist die Höhe des Freibetrags."),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("jahre",
                  "Vermögensverteilung nach 0 bis 1000 Jahren:",
                  min = 0,
                  max = 1000,
                  value = 0),
    sliderInput("steuersatz",
                "bei einem Steuersatz von 0 bis 100%:",
                min = 0,
                max = 100,
                value = 20),
    selectInput("freibetragszenario", "Szenario für den Freibetrag:", 
              choices = c("500.000 CHF"="500k", "1 Million CHF"="1M", "2 Millionen CHF"="2M","3 Millionen CHF"="3M","5 Millionen CHF"="5M","10 Millionen CHF"="10M"),selected="2M")
  ),
  
  # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot",width="100%")
    )
  ),
  tags$h3("Annahmen und Details zur Umsetzung"),
  tags$p("Unter der ambitionierten Annahme, dass keine legalen und illegalen Steuertricks zur Vermeidung einer Erbschaftssteuer angewandt werden (z.B. Umwandlung von Privat- in Betriebsvermögen, Kunstkauf, Nicht-Deklarieren von Vermögen), sind drei Parameter wichtig, um die Umverteilungswirkung der Steuer zu bestimmen. Die ersten beiden sind relativ offensichtlich: Der Freibetrag und der Steuersatz. Diese wurden in der Initiative mit 2 Millionen und 20 Prozent konzipiert. Der dritte und weniger offensichtliche Parameter ist die Dauer, bis ein und derselbe Franken erneut vererbt wird. Hieraus bestimmt sich, innerhalb welchen Zeitraums die 20 Prozent Steuern tatsächlich erhoben werden. Aus den Berner Steuerdaten können wir berechnen, dass pro Jahr etwa ein sechzigstel der Vermögen über 2 Millionen Franken vererbt oder verschenkt werden. Bis 20 Prozent der steuerbaren Masse besteuert wurden, vergehen demnach etwa 60 Jahre.  Wir nehmen weiter an, dass diese Steuereinnahmen gleichmässig auf die gesamte Bevölkerung verteilt werden. Der Rest der Verteilung wird als fix über die Zeit angenommen, d.h. die Simulation abstrahiert von potentiellen sonstigen Vermögensänderungen. Eine weitere implizite Annahme der Simulation ist, dass Vermögen nur innerhalb von Bern vererbt werden, bzw. Vermögen, die durch Vererbung den Kanton verlassen und solche, die dem Kanton zufliessen, sich gegenseitig aufheben.")
  ))