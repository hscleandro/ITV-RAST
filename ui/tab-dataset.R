# ITV-RAST: Omics Integrated analysis in metagenomic samples
# Author: Leandro Corrêa

# --- Dataset tab UI --- #

tabPanel(
  title = "Dataset",
  id    = "datasetTab",
  value = "datasetTab",
  name  = "datasetTab",
  class = "fade in",
  icon  = icon("table"),
  
  tabsetPanel(
    id = "datasetTabs", type = "tabs",    
    
    # ============================tab for uploadinAvailable on the platformg a new dataset======================================
    tabPanel(
      title = "Upload result tools",
      id = "newDatasetTab",
      h3(strong("Upload result of metagenomic and proteomic analysis"),
         helpPopup("The results of this analyzes will be stored in the database and will be available for analysis on this platform.")
      ),
      br(),
      column(width = 4,
    # ============================Kaiju output Files====================================================
        div(id = "div_uploadKaijuFiles",
        fileInput(
          "uploadKaijuFiles", 
          div("Kaiju output File (CDS)", 
              helpPopup("Input file containaing .out or .names extension according to the results of the kaiju tool for the CDS identified by 
                   the EMG pipeline. This file should describe all taxons identified in the analysis, as well as the example bellow."),
              br(), downloadLink("kaijuDataFile", "Example data file")
          ),
          multiple = TRUE,
          accept = c(
            '.names',
            '.out'
          )
        )),
        #hidden(
         # div(id = "upload_msg")),
    # ============================KAAS output Files====================================================
        div(id = "div_uploadKAASFiles",
         fileInput(
          "uploadKAASFiles", 
          div("KAAS output File (CDS)", 
              helpPopup("Input file containing .kaas extension according to the results of the KAAS tool from the ORFs identified in the EMG pipeline."),
              br(), downloadLink("kaasResultsFile", "Example data file")
          ),
          multiple = TRUE,
          accept = c(
            '.kaas'
          )
        )),
       # hidden(
       #    div(id = "upload_msg2")),
    # ============================Proteomic output Files=================================================
        div(id = "div_uploadProteomicFiles",
            fileInput(
              "uploadProteomicFiles", 
              div("Proteomic Analysis", 
                  helpPopup("File containing the .fasta result of proteomic analyse."),
                  br(), downloadLink("proteomicResultsFile", "Example data file")
              ),
              multiple = TRUE,
              accept = c(
                '.fasta',
                '.faa',
                '.fnn'
              )
            )),
      #  hidden(
      #  div(id = "upload_msg3")),
    # ============================Submit Button=========================================================
      actionButton("resetUploadFiles", "Reset fields"),
      
      withBusyIndicator(
          actionButton(
            "uploadFilesBtn",
            "Upload data",
            class = "btn-primary"
          )
        )
        
       # actionLink("resetUploadFiles", "Reset all fields")
      ),
    # ============================InterPro output Files =================================================  
      column(width = 4,
           div(id = "div_uploadInterProFiles",
               fileInput(
                 "uploadInterProFiles", 
                 div("InterPro output File", 
                     helpPopup("File containing the .tsv table of InterPro tool obtained from EMG pipeline. The .tsv file must contain 15 fields, as well as the example bellow."),
                     br(), downloadLink("interProResultsFile", "Example data file")
                 ),
                 multiple = TRUE,
                 accept = c(
                   '.tsv')
               )),
        #   hidden(
        #     div(id = "upload_msg4")),
    # ============================Blast output Files=================================================   
           div(id = "div_uploadBlastFile",
           fileInput(
             "uploadBlastFile",
             div("Blast output File",
                 helpPopup("Input file containg .out extension obtained from HTC_bio Blast, as well as example bellow."),
                 br(), downloadLink("blastResultsFile", "Example results file")
             ),
             multiple = FALSE,
             accept = c(
               '.out'
             )
           )),
        #   hidden(
        #     div(id = "upload_msg5")),
    # ============================Metadata output Files=================================================    
           div(id = "div_uploadMetaFile",
               fileInput(
                 "uploadMetaFile",
                 div("Metadata file (optional)",
                     helpPopup("File containg the metadata of sequences. This file must contain two columns titled: Index and Requirement, as in the example bellow."),
                     br(), downloadLink("metadataResultsFile", "Example results file")
                 ),
                 multiple = FALSE,
                 accept = c(
                   'text/csv',
                   'text/comma-separated-values',
                   '.csv'
                 )
               ))
          )
    ),
    # ============================tab for loading existing dataset=======================================
    tabPanel(
      title = "Input Fasta file",
      id = "loadDatasetTab",
      h3(strong("Upload fasta file"),
         helpPopup("Input fasta files containg the sequences for all analysis available on the platform.")
         ),
      br(),
      fileInput(
        "loadFile",
        "Fasta input File",
        multiple = FALSE,
        accept = c(
          '.fasta'
        )
      ),
      withBusyIndicator(
        actionButton(
          "loadFileBtn",
          "Load data",
          class = "btn-primary"
        )
      )
    )
    
    # tab for loading sample dataset ----
#    tabPanel(
#      title = "Use sample dataset",
#      id = "sampleDatasetTab",
#      h3(strong("Use sample dataset")),
#      br(),
#      selectInput("sampleDatasetType", "Choose a dataset to load",
                  #c("Small dataset" = "small", "Large dataset" = "large")
#                  c("small dataset" = "small", "multiples samples" = "multiple")
#      ),
#      br(),
#      withBusyIndicator(
#        actionButton(
#          "loadSampleBtn",
#          "Load data",
#          class = "btn-primary"
#        )
#      )
#    )
  )
)

