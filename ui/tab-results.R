# ddPCR R package - Dean Attali 2015
# --- Results tab UI --- #
library(jsonlite)

tabPanel(
  title = "Results",
  id    = "resultsTab",
  value = "resultsTab",
  name  = "resultsTab",
  class = "fade",
  icon  = icon("bar-chart"),
  
  conditionalPanel(
    condition = "output.datasetChosen",
  
    tabsetPanel(
      id = "resultsTabs", type = "tabs",    
      
      # Plate data tab ----
      tabPanel(
        title = "Summary",
        id    = "metaTab",
        value = "metaTab",
        name  = "metaTab",
        br(),br(),
        #sidebarLayout(
        fixedRow(
          
          column(3, 
            strong(span("Stacked Plot", id = "cluster")),
            br(),br(),
            wellPanel(
            #sidebarPanel(
            strong(span("Filter by taxon:")),
            uiOutput("list_taxon"),
          
            strong(span("Filter by name:")),
            uiOutput("list_name"),

            uiOutput("range_taxon"), 
            
            strong(span("Output Analytics:")),
            uiOutput("list_analytics"),
            br(),br(),
            withBusyIndicator(
              actionButton(
                "Submit_tax",
                "Submit",
                
                class = "btn-primary"
              )
            )),
            br(),br(),br(),br(),br(),br(),br(),
            strong(span("Cluster Analysis", id = "cluster")),
            br(),br(),
            wellPanel(
              strong(span("Distance Metric:")),
              selectInput(inputId = "distance_metric", 
                          label = "",
                          choices = c("euclidean",
                                      "maximum",
                                      "manhattan",
                                      "canberra",
                                      "binary",
                                      "minkowski")
              ),
              strong(span("Linkage Algorithm:")),
              selectInput(inputId = "linkage_algorithm", 
                          label = "",
                          choices = c("complete",
                                      "single",
                                      "average",
                                      "centroid",
                                      "median",
                                      "mcquitty",
                                      "ward.D",
                                      "ward.D2")
              ),
              strong(span("Nboot:")),
              numericInput("obs", "", 1000, value = 1000),
              br(),
              sliderInput("alfa", 
                          label = "alfa threshould",
                          min = 0, 
                          max = 1,
                          value = 0.95,
                          step = 0.01
              ),
              br(),br(),
              withBusyIndicator(
                actionButton(
                  "Submit_est",
                  "Run",
                  
                  class = "btn-primary"
                )
              )
            )
          ),
          #sidebarPanel(br()),
          column(9,
            #br(),
            #wellPanel(
              #DT::dataTableOutput('resultTableDB', width = "100%")
              plotOutput("plot_taxons", height = 700),
              br(),
              plotOutput("plot_dendo", height = 500)
            )
          )
        )
      )
      
    )
  )
#)