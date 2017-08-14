# ddPCR R package - Dean Attali 2015
# --- Analyze tab server --- #

observeEvent(input$refreshOverviewTable, {
  data <- as.data.frame(dataTableFiles$bd)
  res <- status_Data()
  res <- as.data.frame(res)
  
  dataTableFiles$bd <- res

})

shinyInput = function(FUN, len, id, ...) {
  inputs = character(len)
  for (i in seq_len(len)) {
    inputs[i] = as.character(FUN(paste0(id, i), label = NULL, ...))
  }
  inputs
}

# obtain the values of inputs
shinyValue = function(id, len) {
  unlist(lapply(seq_len(len), function(i) {
    value = input[[paste0(id, i)]]
    if (is.null(value)) NA else value
  }))
}

MetaDataDB <- reactive({
  
  data <- status_Data()
  s <- input$dataTableDB_rows_selected
  if(!is.null(s)){
    #project <- "LAKES"
    #sample <- "AM1"
    project <- data$Project[s]
    sample <- data$Sample[s]
    
    #project <- "LAKES"
    #sample <- "AM1"
    
    metadata <- samples$find(query = paste0('{"$and":[{"project" : "', project,'","sample_name" : "', sample,'"}]}'))
    metadata <- t(metadata)
    Requirements <- rownames(metadata)
    Index <- metadata[,1]
    
    dataMT <- cbind(Requirements,Index)
    dataMT <- as.data.frame(dataMT, row.names = F)
    
    retire <- c("kaiju_tool","kaas_tool","interpro_tool","blast_tool","funn_tool","metadata_tool","sample_status","proteomic_tool")
    index <- which(dataMT$Requirements %in% retire)
    if(length(index) > 0)
      dataMT <- dataMT[-index,]
  }
  else{
    dataMT <- cbind(c(""),c(""))
    colnames(dataMT) <- c("Requirements","Index")
  }
  
  dataMT
})

observeEvent(input$addSample, {
  #query_result()
  s <- input$dataTableDBone_rows_selected
  data <- as.data.frame(dataTableFiles$bd)
  
  if(!is.null(dataTableFiles$bd_one)){
    dataTableFiles$bd_one <- rbind(dataTableFiles$bd_one, data[s,c(1,2)])
    dataTableFiles$bd_one <- unique(dataTableFiles$bd_one)
  }
  else{
    dataTableFiles$bd_one <- data[s,c(1,2)]
  }
  output$analysis <- reactive({ FALSE })
})

observeEvent(input$RemoveSample, {
  
  if(!is.null(dataTableFiles$bd_one)){
    s <- input$dataTableSubmit_rows_selected
    if(length(s) > 0){
      data <- dataTableFiles$bd_one
      data <- data[-s,]
    
      dataTableFiles$bd_one <-  data
    }
  }
  output$datasetChosen <- reactive({ FALSE })
  
})

query_result <-  reactive({
  res <- status_Data()
  res <- as.data.frame(res)
  
  dataTableFiles$bd <- res
})


# render the table containing shiny inputs
output$dataTableDB = DT::renderDataTable({
  query_result()
  data <- dataTableFiles$bd
  DT::datatable(
    data, escape = FALSE, selection = 'single', extensions = 'Responsive', 
    rownames= FALSE
   #   options = list(
   #    preDrawCallback = JS('function() { Shiny.unbindAll(this.api().table().node()); }'),
   #    drawCallback = JS('function() { Shiny.bindAll(this.api().table().node()); } ')
   # )
  )
})

output$dataTableDBone = DT::renderDataTable({
  query_result()
  data <- dataTableFiles$bd
  DT::datatable(
    data, escape = FALSE, selection = 'multiple', extensions = 'Responsive', 
    rownames= FALSE
    #   options = list(
    #    preDrawCallback = JS('function() { Shiny.unbindAll(this.api().table().node()); }'),
    #    drawCallback = JS('function() { Shiny.bindAll(this.api().table().node()); } ')
    # )
  )
})

output$dataTableMetaDB <- DT::renderDataTable({
  
  data <- MetaDataDB()
  DT::datatable(data, options = list(lengthChange = FALSE,
                                     lengthMenu = c(10, 25, 50), pageLength = 10 ), rownames= FALSE
  )
})

output$dataTableSubmit <- DT::renderDataTable({
  
  data <- dataTableFiles$bd_one
  DT::datatable(data, options = list(lengthChange = FALSE,
                                     lengthMenu = c(10, 25, 50), pageLength = 10 ), rownames= FALSE
  )
})


output$downloadMetaData <- downloadHandler(
   filename = function() {
     paste('data-', Sys.Date(), '.csv', sep='')
   },
   content = function(con) {
     write.csv(data, con)
   }
)

#output$x2 = renderPrint({
  
#  data.frame(Pick = shinyValue('v2_', 30))
#})

observeEvent(input$analyzeBtn, {
  withBusyIndicator("analyzeBtn", {
    # html("analyzeProgress", "")
    # withCallingHandlers(
    #   dataValues$plate <- dataValues$plate %>% analyze(restart = TRUE),
    #   message = function(m) {
    #     html("analyzeProgress", m$message, TRUE)
    #   },
    #   warning = function(m) {
    #     html("analyzeProgress", paste0(m$message, "\n"), TRUE)
    #   }
    # )
   
    show("analyzeNextMsg")
  })
})

# change to results tab when clicking on link
observeEvent(input$toResults, withBusyIndicator("uploadFilesBtn", {            
    output$datasetChosen <- reactive({ TRUE })
    updateTabsetPanel(session, "mainNav", "resultsTab")
  })
)