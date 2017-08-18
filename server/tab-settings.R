# ddPCR R package - Dean Attali 2015
# --- Settings tab server --- #

# Update the settings whenever the plate gets updated

#output$x4 = renderPrint({
#  s = input$dataTableRemove_rows_selected
#  if (length(s)) {
#    cat('These rows were selected:\n\n')
#    cat(s, sep = ', ')
#  }
#})

output$selectSample <- renderUI({
  
  project <- as.character(input$project) 
  sample <- samples$distinct("sample_name", query = paste0('{"project" : "',project,'"}'))
  if(length(sample) == 0){
    selectInput("sample", "", c("Select Sample",""))  
  }
  else{
    selectInput("sample", "", c("Select Sample",sample))  
    
  }
  
})

#output$updateProjectServer <- reactive({
#  updateProject <- input$showNewProject + input$updateProject
#  cat("variavel:", variable$updateproject,"\n")
#  updateProject
#})

observeEvent(input$updateProject, {
  input <- input$add_project
  input <- toupper(input)
  query <- samples$count(query = paste0('{"project" :"', input,'"}'))
  if((query == 0)&(input != "")){
    samples$insert(data = paste0('{"project" :"', input,'"}'))  
  }

  updateSelectInput(session, "project",
                    choices = c("Select Project",samples$distinct("project")),
                    selected = input
  )
  
  updateTextInput(session, "add_project", value = "")

}) 

observeEvent(input$updateSample, {
  sample <- toupper(input$add_sample)
  project <- input$project

  query <- samples$count(query = paste0('{"$and":[{"project" :"', project,'","sample_name" :"', sample,'"}]}'))
  if((query == 0)&(project != "Select Project")&(project != "")&(sample != "")){
    count_p <- samples$count(query = paste0('{"$and" : [{"project" : "', project,'","sample_name": {"$exists": false}}]}'))
    if(count_p == 1){
      samples$update(query = paste0('{"project":"', project,'"}'),
                     update = paste0('{"$set":{"sample_name":"', sample,'",
                                               "sample_status":"OK"}
                                       }')   
      )
    }
    else 
    { 
      samples$insert(data = paste0('{"project" :"', project,'"}'))
      samples$update(query = paste0('{"$and" : [{"project" : "', project,'","sample_name": {"$exists": false}}]}'),
                     update = paste0('{"$set":{"sample_name":"', sample,'",
                                               "sample_status":"OK"}
                                       }')
                    )    
    }
  }

  updateSelectInput(session, "sample",
                    choices = c("Select Project",samples$distinct("sample_name", query = paste0('{"project" : "',project,'"}'))),
                    selected = sample
  )
  
  updateTextInput(session, "add_sample", value = "")
}) 

shinyInput <- function(FUN,id,num,...) {
  inputs <- character(num)
  for (i in seq_len(num)) {
    inputs[i] <- as.character(FUN(paste0(id,i),label=NULL,...))
  }
  inputs
}

rowSelect <- reactive({
  
  rows=names(input)[grepl(pattern = "srows_",names(input))]
  paste(unlist(lapply(rows,function(i){
    if(input[[i]]==T){
      return(substr(i,gregexpr(pattern = "_",i)[[1]]+1,nchar(i)))
    }
  })))
  
})

output$dataTable <- DT::renderDataTable({

  DT::datatable(dataTableFiles$table[,c(1,2,3,4)], 
                options = list(lengthChange = FALSE,
                               ############
                               initComplete = JS(
                                 "function(settings, json) {",
                                 "var headerBorder = [0,0];",
                                 "var header = $(this.api().table().header()).find('tr:first > th').filter(function(index) {return $.inArray(index,headerBorder) > -1 ;}).addClass('cell-border-right');",
                                 "}"),columnDefs=list(list(className="dt-right cell-border-right",targets=1)),
                               ############
                               pageLength = 10, sDom  = '<"top">lrt<"bottom">ip'), rownames= FALSE
  )
})

DataREMOVE <-reactive({
  if(input$remove_inp != "All"){
    input_tool <- c("PROJECT","SAMPLE",toupper(input$remove_inp))
  }
  else{
    input_tool <- c("PROJECT","SAMPLE","STATUS")
  }
  data <- status_Data()
  namesc <- toupper(colnames(data))
  index_tool <- which(namesc %in% input_tool)
  data <- data[,index_tool]
  
  #dataTableFiles$remove <- data
  dataTableFiles$remove <- data
  
  #data
  
})

observeEvent(input$refreshRemoveTable, {
  if(input$remove_inp != "All"){
    input_tool <- c("PROJECT","SAMPLE",toupper(input$remove_inp))
  }
  else{
    input_tool <- c("PROJECT","SAMPLE","STATUS")
  }
  data <- status_Data()
  namesc <- toupper(colnames(data))
  index_tool <- which(namesc %in% input_tool)
  data <- data[,index_tool]
  
  #dataTableFiles$remove <- data
  dataTableFiles$remove <- data
  
})

output$dataTableRemove <- DT::renderDataTable({
  DataREMOVE()
  data <- dataTableFiles$remove
  DT::datatable(data, 
                extensions = 'Responsive', 
                options = list(orderClasses = TRUE,
                               lengthChange = FALSE,
                               #autoFill = TRUE,
                               #lengthChange = FALSE,
                               #lengthMenu = c(10, 25, 50),
                               pageLength = 10 
                               #sDom  = '<"top">lrt<"bottom">ip',
                ),
                #rownames= FALSE
                #selection='none', 
                escape=F, selection =  'multiple', rownames= FALSE
                
  )
  #DT::datatable(dataTableFiles$table[,c(1,2,3,4)], 
  #              options = list(lengthChange = FALSE,
                               ############
              
                               ############
  #                             pageLength = 10), rownames= FALSE
  #)
})

# update basic settings button is clicked
observeEvent(input$updateBasicSettings, {
  withBusyIndicator("updateBasicSettings", {
    # if a new plate type is chosen, need to reset the plate
    s = input$dataTable_rows_selected
    
    if((input$project != "Select Project")&(!is.null(s))){
      dataTableFiles$table$Project[s] <- input$project
    }
    
    if((input$sample != "Select Sample")&(!is.null(s))){
      dataTableFiles$table$Sample[s] <- input$sample
    }
    updateTextInput(session, "settingsSubset", value = "")
  })
})

# subset plate button is clicked
observeEvent(input$updateSubsetSettings, {
  withBusyIndicator("updateSubsetSettings", {
    dataValues$plate <- subset(dataValues$plate, input$settingsSubset)
    updateTextInput(session, "settingsSubset", value = "")
  })
})   

# Advanced settings ----


# reset settings to default
observeEvent(input$resetParamsBtn, {
  withBusyIndicator("resetParamsBtn", {
    disable("updateAdvancedSettings")
    dataValues$plate <- set_default_params(dataValues$plate)
    enable("updateAdvancedSettings")
  })
})

observeEvent(input$removeBasicSettings, {
  withBusyIndicator("removeBasicSettings", {
  #updateTabsetPanel(session, "mainNav", "analyzeTab"){
  tool <- input$remove_inp
  s = input$dataTableRemove_rows_selected
  data <- dataTableFiles$remove
  data <- data[s,]
  
  data <- as.data.frame(data)
  for(i in 1:nrow(data)){
    cat(data[i,1],"-",data[i,2],"-",data[i,3],"\n")
    if(tool == "All"){
      remove_metegenomics_db(data[i,1],data[i,2],tool)
    }
    else if(data[i,3] == "OK"){
      remove_metegenomics_db(data[i,1],data[i,2],tool)
      
    }
  }
  dataTableFiles$remove <- DataREMOVE()
  #insert_metegenomics_db(data$Path[s],data$Project[s],data$Sample[s],data$Tool[s])
  #updateTabsetPanel(session, "mainNav", "analyzeTab")
  })
  
})

# change to analyze tab when clicking on link
observeEvent(input$toAnalyze, {
  #updateTabsetPanel(session, "mainNav", "analyzeTab"){
  data <- dataTableFiles$table
  data <- as.data.frame(data)
  if(nrow(data) > 0){
    for(i in 1:nrow(data)){
      file <- dataTableFiles$table[i,1]
      
      oldNames = data$Path[i]
      newNames = file.path(dirname(oldNames),
                           file)
      file.rename(from = oldNames, to = newNames)
      
      #cat("oldnames:",oldNames,"\n")
      #cat("newnames:",newNames,"\n")
      
      newPath <- paste0(temp_var,file)
      #cat("newPath:",newPath,"\n")
  
      comand <- paste0("cp ",newNames," ",newPath)
      
      #file.copy(newNames, newPath)
      system(command = comand, wait = TRUE)
      
      #comand <- paste0("python /srv/shiny-server/itv-rast/metagenomics-database/kaiju_mongo.py -i /srv/shiny-server/itv-rast/files/temp/mgm4723928.fnn.kaiju.out.names -s MG34_MGRAST_N -p CANGA")
      #cat("insert_metegenomics_db(",newPath,",",data$Project[i],",",data$Sample[i],",",data$Tool[i],")\n")
      insert_metegenomics_db(newNames,data$Project[i],data$Sample[i],data$Tool[i])
      #system(command = comand, wait = FALSE)
    }
  }
  
  updateTabsetPanel(session, "mainNav", "analyzeTab")
  
  
})
