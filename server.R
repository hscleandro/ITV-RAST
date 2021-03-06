# ITV-RAST: Omics Integrated analysis in metagenomic samples
# Author: Leandro Corrêa

library(shiny)
library(shinyjs)
library(DT)
library(mongolite)
library(dplyr)
library(RColorBrewer)

config <- read.table(file = paste0(getwd(),'/setup.conf'))

host <- config$V3[1]
port <- as.numeric(config$V3[2])
temp_var <- config$V3[3]


samples = mongo(collection = "samples", db = "local", url = paste0("mongodb://",host,":",port),
                verbose = FALSE, options = ssl_options())

source("dbase.R")

# allow uploading files up to 300MB
options(shiny.maxRequestSize = 700*1024^3) 

source(file.path("server", "helpers.R"))

shinyServer(function(input, output, session) {
  
  # reactive values we will use throughout the app
  dataValues <- reactiveValues(
    plate = NULL
  )
  
  dataTableFiles <- reactiveValues(
    table = NULL,
    path = NULL,
    bd = NULL,
    remove = NULL,
    bd_one = NULL, 
    taxons = NULL,
    taxons_inf = NULL,

    kaiju = 0,
    kaas = 0,
    interPro = 0,
    proteomic = 0,
    blast = 0,
    meta = 0
    
  )
  
  dataTools <- reactiveValues(
    kaiju = NULL,
    kaas = NULL,
    interpro = NULL,
    blast = NULL,
    proteomic = NULL
    
  )
 
  status_Data <- function(){
    
    data <- samples$find(fields = '{
                         "project" : "",                          
                         "sample_name" : "",
                         "kaas_tool" : "",
                         "kaiju_tool" : "",
                         "interpro_tool" : "",
                         "blast_tool":"",
                         "proteomic_tool":"",
                         "metadata_tool": "",
                         "sample_status":"",
                         "funn_tool":""}')
    name_col <- c("project","sample_name","blast_tool","funn_tool","interpro_tool","kaas_tool","kaiju_tool","proteomic_tool",
                  "metadata_tool", "sample_status")
    data_result <- matrix(data = "----", ncol = length(name_col), nrow = nrow(data))
    data_result <- as.data.frame(data_result)
    data_result[is.na(data_result)] <- "----"
    colnames(data_result) <- name_col
    data <- data[,-1]
    if(nrow(data) > 0){
      for(i in 1:length(colnames(data))){
        name <- colnames(data)[i]
        index_na <- which(is.na(data[,name]))
        data_result[,name] <- data[,name] 
        if(length(index_na) > 0)
          data_result[index_na,name] <- "----"
      }
    }
    
    colnames(data_result) <- c("Project","Sample","blast","funn","Interpro","kaas","kaiju","proteomic","metadata","status")
    #                       1        2       3       4         5        6         7          8         9            10
    
    return(data_result)
}
  
  # we need to have a quasi-variable flag to indicate whether or not
  # we have a dataset to work with or if we're waiting for dataset to be chosen
  output$datasetChosen <- reactive({ FALSE })
  outputOptions(output, 'datasetChosen', suspendWhenHidden = FALSE)
  
  output$analysis <- reactive({ FALSE })
  outputOptions(output, 'analysis', suspendWhenHidden = FALSE)
 
  # When a main or secondary tab is switched, clear the error message
  # and don't show the dataset info on the About tab
  observe({
    input$mainNav
    input$datasetTabs
    input$settingsTabs
    input$resultsTabs
    
    # don't show the dataset description in About tab
    toggle(id = "headerDatasetDesc",
           condition = input$mainNav != "aboutTab")
    
    # clear the error message
    hide("errorDiv")
    
    # hide the "finished, move on to next tab" messages
    hide("analyzeNextMsg")
  })
  
  # include logic for each tab
  source(file.path("server", "tab-dataset.R"),   local = TRUE)$value
  source(file.path("server", "tab-settings.R"),  local = TRUE)$value
  source(file.path("server", "tab-analyze.R"),   local = TRUE)$value
  source(file.path("server", "tab-results.R"),   local = TRUE)$value
  
  # hide the loading message
  #Sys.sleep(2)  
  hide("loading-content", TRUE, "fade")  
 
  })
