
# ui.R
library(shiny)
library(plotly)
library(highlight)

shinyUI(fluidPage(
  
  titlePanel("Site selection and clustering analysis tool"),
  fluidRow(tags$a(href='readme.html', target='blank', "Instructions")),
  
  # the top row is the user selection menus for PSNU and time period
  fluidRow(
        column(width=6, selectizeInput("psnu", "Select district:",
                  sort(as.vector
                               (unique(sitedata$PSNU))
                       ),
                  selected="gp City of Johannesburg Metropolitan Municipality"),
                  checkboxInput("markertype","Colored circle markers:")),
        
        br(),
  
        column(width=6, selectInput("fiscalperiod", "Select period:",
                              sort(as.vector
                                           (unique(sitedata$variable))
                                   ),
                              selected="FY2018Q2"))
        ),
        
        hr(),
  
  # Then the next row is the output including text, map, and scatterplot   
  fluidRow(
          column(2,textOutput("HTStxt1"),tags$div(summarywidgetOutput("HTSagg"),style="strong"),textOutput("HTStxt2"),
                summarywidgetOutput("HTSPOSagg"),textOutput("HTStxt3"),summarywidgetOutput("TXagg"),
                textOutput("TXtxt1")),
          
          column(5,leafletOutput("map")),
          
          column(5,d3scatterOutput("scatter")),
          
          hr(),
         div(DT::dataTableOutput("dt"), style = "font-size:80%")
      )
      
  ))
         
        
               