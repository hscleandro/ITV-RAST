# ddPCR R package - Dean Attali 2015
# --- Settings tab UI --- #

tabPanel(
  title = "Settings",
  id = "settingsTab",
  value = "settingsTab",
  name = "settingsTab",
  class = "fade",
  icon  = icon("cog"),
  
  #conditionalPanel(
    #condition = "output.datasetChosen",
    tabsetPanel(
      id = "settingsTabs", type = "tabs",    
      
      # Basic settings tab
      tabPanel(
        title = "Add data",
        id    = "basicSettingsTab",
        value = "basicSettingsTab",
        name  = "basicSettingsTab",
        br(),
        
        div(id = "basicSettingsTabContent",
        h3(strong("Select name of the samples and projects of the uploaded files"),
           helpPopup("Click the name of the samples shown in the form on the right side and 
                     modify the fields using the data entry fields located on the left side.")
        ),
        br(),
        fixedRow(
          column(4, wellPanel(
            # ============================Information about samples======================================
            #strong(id = "partner_id", span("Partner id:")),
            #textInput("caption", "", "1-10;12;14"),
            strong(id = "project_id", span("Project:")),
            # ============================Set project names============================================== 
            selectInput(
              "project", "",
              c("Select Project",samples$distinct("project")),
              selected = "all"),
            # ============================Add new projects================================================
            actionLink("showNewProject", "Add new project"),
            conditionalPanel(
              condition = "input.showNewProject % 2 == 1",
              textInput("add_project", "", "New project"),
              withBusyIndicator(
                actionButton(
                  "updateProject",
                  "Ok",
                  class = "btn-addproject"
                )
              )
            ),
            #
            br(), br(),
            # ============================Set sample names============================================== 
            strong(id = "sample_id", span("Sample:")),
            uiOutput("selectSample"),
            #selectInput(
            #  "sample", "",
            #  c("Select Sample","f","g","h","i","j"),
            #  selected = "all"),
            # ============================Add new sample================================================
            actionLink("showNewSample", "Add new sample"),
            conditionalPanel(
              condition = "input.showNewSample % 2 == 1",
              #conditionalPanel(
                #strong(id = "new_sample", span("Add new sample:")),
              textInput("add_sample", "", "New sample"),
              withBusyIndicator(
                actionButton(
                  "updateSample",
                  "Ok",
                  class = "btn-addsample"
                )
              )
              #)
            ),
            # ============================submit informations================================================
            br(),br(),
            withBusyIndicator(
              actionButton(
                "updateBasicSettings",
                "Apply",
                class = "btn-primary"
              )
            )
          )
            
          ),
          column(1),
          column(6,
                 tags$head(
                   tags$style(HTML(".cell-border-right{border-right: 1px solid #000}"))),
                 DT::dataTableOutput('dataTable')
          )
        )),
        #br(),
        HTML("<br>"),
        div(
          id = "settingsNextMsg",
          class = "next-msg",
          # "When you are finished with the settings,",
          # actionLink("toAnalyze", "continue to Analyze")
          actionButton(
            "toAnalyze",
            "continue to Analyze",
            class = "btn-primary"
          )
        )
        
      ),

      # Subset plate tab
      tabPanel(
        title = "Remove data",
        id = "subsetSettingsTab",
        br(),
        h3(strong("Select the samples you want delete"),
           helpPopup("(1) Select the result according to the tool you want to delete. (2) Select the sample and project by 
                     clicking on the table next to it. (3) Click the Remove button.")
        ),
        br(),
        fixedRow(
          column(4, wellPanel(
            strong(id = "project_id", span("Select tool:")),
            selectInput(
              "remove_inp", "",
              c("Kaiju","Kaas","Blast","InterPro","Proteomic","Metadata","All"),
              selected = "Metadata"),
            br(),br(),
            withBusyIndicator(
              actionButton(
                "removeBasicSettings",
                "Remove",
                class = "btn-primary"
              )
            )
          )#,
          
          #verbatimTextOutput('x4')
        ),
        column(8,
               wellPanel(
                 DT::dataTableOutput('dataTableRemove')
               ),
               actionButton("refreshRemoveTable", "Refresh table")
        )
        )
      )
    )
    
  #)
)