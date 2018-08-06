# server.R
library(shiny)
library(plotly)
library(highlight)
library(crosstalk)

# load datasets
# load(".RData")


tentensites <- filter(sitedata,ten=="yes")

shinyServer(function(input, output) {
  
# t2 is a reactive dataset that is filtered by PSNU and fiscal period according to user input selections.  
  t2 <- reactive({ 
           filter(sitedata,PSNU==input$psnu & variable==input$fiscalperiod) %>% arrange(sitetype)
        })

# SharedData$new is a function from the crosstalk package that creates a linked dataset called shared_site
# the linked dataset shared_site will be fed into compatible visualizations for interactive linking
  
  shared_site <- crosstalk::SharedData$new(t2)

# pan is a reactive data frame that contains only the coordinates of the centroid of the user-selected PSNU
# it will be used to pan the map to the selected district
  pan <- reactive({
            filter(centroid_data,PSNU==input$psnu) 
         })
  
# prepare static text blocks that to add context to the summary statistics    
  output$HTStxt1 <- renderText("In the selected period, the selected sites have done ")
  output$HTStxt2 <- renderText(" HIV tests, and returned a total of ")
  output$HTStxt3 <- renderText(" positive results. A total of ")
  output$TXtxt1 <- renderText(" treatment-naive patients were initiated on ART.")

# render the summary statistics based on the sites selected in the shared_site linked dataset
  output$HTSagg <- renderSummarywidget({ summarywidget(shared_site, statistic='sum', column='HTS_TST_N', digits=0) })
  output$HTSPOSagg <- renderSummarywidget({ summarywidget(shared_site, statistic='sum', column='HTS_TST_POS_N', digits=0) })
  output$TXagg <- renderSummarywidget({ summarywidget(shared_site, statistic='sum', column='TX_NEW_N', digits=0) })
  

# map using the leaflet package
  output$map <- renderLeaflet({
  
  # put lon / lat coordinates into "coord" based on reactive user selection
  coord <- pan()

  # set the zoom level to 10 if Metropolitan area, 8 if a district area    
    t3 <- t2()
    z <- ifelse(grepl("etropolitan",input$psnu),10,8)
    
    pal <- colorFactor(c("dodgerblue3", "orange", "green", "red", "mediumpurple", "yellow", "brown"), 
              domain = sort(as.vector
                            (unique(t3$sitetype))))
    
    # Allow different type of markers on the map depending on user selection
    if(input$markertype) {
    leaflet(data = shared_site) %>% 
      setView(lng = coord$lon, lat = coord$lat, zoom = z) %>%
      addTiles() %>%
      addPolygons(data = PSNU, group="PSNU") %>%
      addCircleMarkers(group="Sites", radius = ~linkcap,  fillOpacity = 0.85, color = ~pal(sitetype)) %>%
      addLayersControl(overlayGroups = c("PSNU","Sites"))
    }
    
    else {
      leaflet(data = shared_site) %>% 
      setView(lng = coord$lon, lat = coord$lat, zoom = z) %>%
      addTiles() %>%
      addPolygons(data = PSNU, group="PSNU") %>%
      addMarkers(data = shared_site,group="Sites") %>%
      addLayersControl(overlayGroups = c("PSNU","Sites")) 
    }
      
    })
  
   
# scatterplot built specifically for crosstalk cross reactivity
  output$scatter <- renderD3scatter({

    d3scatter(shared_site, ~HTS_TST_POS_N, ~TX_NEW_N, t2()$sitetype)

    })

  
# site list in data.table  
  output$dt <- DT::renderDataTable({
    
    DT::datatable(shared_site, filter="top", 
                  colnames=c("District", "Community", "Facility", "Period", 
                             "HIV tests", "Positive", "TX_CURR", "TX_NEW", "TX_RET_D", "TX_RET_N", 
                             "linkage", "linkage (capped at 300%)", "latitude", "longitude", "Site Type",
                             "10/10 site"), rownames=FALSE) %>%
    formatPercentage(c("linkage","linkcap"),digits=2)
  
    }, server = FALSE)

})
