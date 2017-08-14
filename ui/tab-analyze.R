# ddPCR R package - Dean Attali 2015
# --- Analyze tab UI --- #

tabPanel(
  title = "Analyze",
  id    = "analyzeTab",
  value = "analyzeTab",
  class = "fade",
  icon  = icon("calculator"),
  
  #conditionalPanel(
    #condition = "output.datasetChosen", 
    tabsetPanel(
      id = "overViewTabs", type = "tabs", 
      tabPanel(
        title = "Add samples",
        id = "clusterSettingsTab",
        fixedRow(
          column(7, 
            br(),br(),
            h3(strong("Sample stored on the platform"),
               helpPopup('Select the samples that will be analyzed from the "Pick" option, 
                           and perform the analyzes by pressing the "Run analysis". The "Refresh" 
                           button updates the user about the status of the sample in the database.')
            ),
            br(),
            wellPanel(
              DT::dataTableOutput('dataTableDBone', width = "100%")
            ),
            actionButton("refreshOverviewTable", "Refresh table"),
            actionButton("addSample", "Add Sample")
            
          ),
          column(5,
                 br(),br(),
                 h3(strong("Samples selected for analysis"),
                    helpPopup("Table shows the samples selected for analysis.")
                 ),
                 br(),
                 wellPanel(
                   DT::dataTableOutput('dataTableSubmit', width = "100%")
                 ),
                 actionButton("RemoveSample", "Remove Sample"),
                 withBusyIndicator(
                   actionButton(
                     "analyzeBtn",
                     "Run analysis",
                     class = "btn-primary btn-lg"
                   )
                 ),
                 conditionalPanel(
                   condition = "output.analysis", 
                     pre(id = "analyzeProgress"),
                     hidden(
                       div(
                         id = "analyzeNextMsg",
                         class = "next-msg",
                         "The data has been analyzed, you can",
                         actionLink("toResults", "continue to Results")
                       )
                     )
                 )
          )
        )
        
      ),
      tabPanel(
        title = "View metadata",
        id = "overViewAnalyseTab",
      #p("Analyze the droplets to classify each droplet into a group.", br(),
      #  "This may take several minutes depending on the number of wells."),
        fixedRow(
            column(7,                   
              br(),br(),
              h3(strong("Sample stored on the platform"),
                 helpPopup('Select the sample and see in the table beside the related metadata. The "Refresh" 
                             button updates the user about the status of the sample in the database.')
              ),
              br(),
              wellPanel(
                DT::dataTableOutput('dataTableDB', width = "100%")
              ),
              actionButton("refreshOverviewTable", "Refresh table")
              #verbatimTextOutput('x2')
            ),
            column(5,
                   br(),br(),
                   h3(strong("Metadata of selected sample"),
                      helpPopup("Select a row from the adjacent table and get the information from the related metadata of each sample.")
                   ),
                   br(),
                   wellPanel(
                     DT::dataTableOutput('dataTableMetaDB')
                   ),
                   downloadButton('downloadMetaData', 'Download')#,
                   #pre(id = "downloadMeta")
                   
          )
        )
      )
    )
  #)
)