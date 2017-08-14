# ITV-RAST: Omics Integrated analysis in metagenomic samples
# Author: Leandro Corrêa

# --- Dataset tab server --- #

# only enable the upload buttons when their corresponding input has a file selected
observeEvent(input$uploadKaijuFiles, ignoreNULL = FALSE, {
  toggleState("uploadFilesBtn", !is.null(input$uploadKaijuFiles))
  toggleState("toAnalyze", !is.null(input$uploadKaijuFiles))
})
observeEvent(input$uploadKAASFiles, ignoreNULL = FALSE, {
  toggleState("uploadFilesBtn", !is.null(input$uploadKAASFiles))
  toggleState("toAnalyze", !is.null(input$uploadKAASFiles))
})
observeEvent(input$uploadProteomicFiles, ignoreNULL = FALSE, {
  toggleState("uploadFilesBtn", !is.null(input$uploadProteomicFiles))
  toggleState("toAnalyze", !is.null(input$uploadProteomicFiles))
})
observeEvent(input$uploadInterProFiles, ignoreNULL = FALSE, {
  toggleState("uploadFilesBtn", !is.null(input$uploadInterProFiles))
  toggleState("toAnalyze", !is.null(input$uploadInterProFiles))
})
observeEvent(input$uploadBlastFile, ignoreNULL = FALSE, {
  toggleState("uploadFilesBtn", !is.null(input$uploadBlastFile))
  toggleState("toAnalyze", !is.null(input$uploadBlastFile))
})
observeEvent(input$uploadMetaFile, ignoreNULL = FALSE, {
  toggleState("uploadFilesBtn", !is.null(input$uploadMetaFile))
  toggleState("toAnalyze", !is.null(input$uploadMetaFile))
})

observeEvent(input$loadFile, ignoreNULL = FALSE, {
  toggleState("loadFileBtn", !is.null(input$uploadProteomicFiles))
})

# when "Upload data" button is clicked
observeEvent(input$uploadFilesBtn, {
  withBusyIndicator("uploadFilesBtn", {
    dataTableFiles$table <- NULL
    if((!is.null(input$uploadKaijuFiles))&(dataTableFiles$kaiju == 1)){
      
      file <- input$uploadKaijuFiles
      Files <- file$name
      
      Tool <- rep("kaiju",length(Files))
      Path <- file$datapath
      
      if(is.null(Files)){
        Files <- "samples.names"
        Path <- "NULL"
      }
      list_Files <- strsplit(Files,"[.]")
      Sample <- NULL
      for(i in 1:length(list_Files)){
        Sample[i] <- list_Files[[i]][1]
      }
      #Sample <- rep("sample_test",length(Files))
      Project <- rep("unknown",length(Files))
      data <- cbind(Files, Tool, Sample, Project, Path)
      data <- as.data.frame(data)
      
      dataTableFiles$table <- data
      dataTableFiles$path <- Path
    }
    if((!is.null(input$uploadKAASFiles))&(dataTableFiles$kaas == 1)){
      
      file <- input$uploadKAASFiles
      Files <- file$name
      
      Tool <- rep("kaas",length(Files))
      Path <- file$datapath

      Files <- file$name
      if(is.null(Files)&(!is.null(dataTableFiles$table))){
        Files <- "samples.names"
        
      }
      list_Files <- strsplit(Files,"[.]")
      Sample <- NULL
      for(i in 1:length(list_Files)){
        Sample[i] <- list_Files[[i]][1]
      }
      #Sample <- rep("sample_test",length(Files))
      Project <- rep("unknown",length(Files))
      data <- cbind(Files, Tool, Sample, Project, Path)
      data <- as.data.frame(data)
      if(!is.null(dataTableFiles$table)){
        dataTableFiles$table <- rbind(dataTableFiles$table,data)
        dataTableFiles$path <- c(dataTableFiles$path, Path)
      }
      else{
        dataTableFiles$table <- data
        dataTableFiles$path <- Path
      }
    }
    if((!is.null(input$uploadProteomicFiles))&(dataTableFiles$proteomic == 1)){
      
      file <- input$uploadProteomicFiles
      Files <- file$name
      
      Tool <- rep("proteomic",length(Files))
      Path <- file$datapath
      
      Files <- file$name
      if(is.null(Files)&(!is.null(dataTableFiles$table))){
        Files <- "samples.names"
        
      }
      list_Files <- strsplit(Files,"[.]")
      Sample <- NULL
      for(i in 1:length(list_Files)){
        Sample[i] <- list_Files[[i]][1]
      }
      #Sample <- rep("sample_test",length(Files))
      Project <- rep("unknown",length(Files))
      data <- cbind(Files, Tool, Sample, Project, Path)
      data <- as.data.frame(data)
      if(!is.null(dataTableFiles$table)){
        dataTableFiles$table <- rbind(dataTableFiles$table,data)
        dataTableFiles$path <- c(dataTableFiles$path, Path)
      }
      else{
        dataTableFiles$table <- data
        dataTableFiles$path <- Path
      }
      
    }
    if((!is.null(input$uploadInterProFiles))&(dataTableFiles$interPro == 1)){
      file <- input$uploadInterProFiles
      Files <- file$name
      
      Tool <- rep("interpro",length(Files))
      Path <- file$datapath
      
      Files <- file$name
      if(is.null(Files)&(!is.null(dataTableFiles$table))){
        Files <- "samples.names"
        
      }
      list_Files <- strsplit(Files,"[.]")
      Sample <- NULL
      for(i in 1:length(list_Files)){
        Sample[i] <- list_Files[[i]][1]
      }
      #Sample <- rep("sample_test",length(Files))
      Project <- rep("unknown",length(Files))
      data <- cbind(Files, Tool, Sample, Project, Path)
      data <- as.data.frame(data)
      if(!is.null(dataTableFiles$table)){
        dataTableFiles$table <- rbind(dataTableFiles$table,data)
        dataTableFiles$path <- c(dataTableFiles$path, Path)
      }
      else{
        dataTableFiles$table <- data
        dataTableFiles$path <- Path
      }
    }
    if((!is.null(input$uploadBlastFile))&(dataTableFiles$blast == 1)){
      file <- input$uploadBlastFile
      Files <- file$name
      
      Tool <- rep("blast",length(Files))
      Path <- file$datapath
      
      Files <- file$name
      if(is.null(Files)&(!is.null(dataTableFiles$table))){
        Files <- "samples.names"
        
      }
      list_Files <- strsplit(Files,"[.]")
      Sample <- NULL
      for(i in 1:length(list_Files)){
        Sample[i] <- list_Files[[i]][1]
      }
      #Sample <- rep("sample_test",length(Files))
      Project <- rep("unknown",length(Files))
      data <- cbind(Files, Tool, Sample, Project, Path)
      data <- as.data.frame(data)
      if(!is.null(dataTableFiles$table)){
        dataTableFiles$table <- rbind(dataTableFiles$table,data)
        dataTableFiles$path <- c(dataTableFiles$path, Path)
      }
      else{
        dataTableFiles$table <- data
        dataTableFiles$path <- Path
      }
      
      
    }
    if((!is.null(input$uploadMetaFile))&(dataTableFiles$meta == 1)){
      file <- input$uploadMetaFile
      Files <- file$name
      
      Tool <- rep("metadata",length(Files))
      Path <- file$datapath
      
      Files <- file$name
      if(is.null(Files)&(!is.null(dataTableFiles$table))){
        Files <- "samples.names"
        
      }
      list_Files <- strsplit(Files,"[.]")
      Sample <- NULL
      for(i in 1:length(list_Files)){
        Sample[i] <- list_Files[[i]][1]
      }
      #Sample <- rep("sample_test",length(Files))
      Project <- rep("unknown",length(Files))
      data <- cbind(Files, Tool, Sample, Project, Path)
      data <- as.data.frame(data)
      if(!is.null(dataTableFiles$table)){
        dataTableFiles$table <- rbind(dataTableFiles$table,data)
        dataTableFiles$path <- c(dataTableFiles$path, Path)
      }
      else{
        dataTableFiles$table <- data
        dataTableFiles$path <- Path
      }
    }
    
    updateTabsetPanel(session, "mainNav", "settingsTab")
  })
})

# when fasta file is uploaded
observeEvent(input$loadFileBtn, {
  withBusyIndicator("loadFileBtn", {
    #file <- input$loadFile %>% fixUploadedFilesNames
    #dataValues$plate <- load_plate(file$datapath)
    file <- input$loadFile
    
    oldNames = file$datapath
    newNames = file.path(dirname(file$datapath),
                         file$name)
    file.rename(from = oldNames, to = newNames)
    
    cat("oldnames:",oldNames,"\n")
    cat("newnames:",newNames)
    
    newPath <- "/home/leandro/Git/mgcomp/backup/teste2.fasta"
    tempfile <- "/home/leandro/Git/mgcomp/backup/execute.pbs"
    comand <- paste0("cp ",newNames," ",newPath)
    
    sink(tempfile)
    cat("#PBS -l nodes=1:ppn=24")
    cat("\n")
    cat("#PBS -N kaiju_emma_newbler_proteinhits_FINAL")
    cat("\n")
    cat("#PBS -o kaiju_emma_newbler_proteinhits_FINAL__0505.log")
    cat("\n")
    cat("#PBS -e kaiju_emma_newbler_proteinhits_FINAL_0505.err")
    cat("\n\n")
    cat(paste0('kaijup -z 24 -t /bio/share_bio/softwares/kaiju/kaijudb/blast_nr/nodes.dmp ', 
                             '-f /bio/share_bio/softwares/kaiju/kaijudb/blast_nr/kaiju_db_nr.fmi ', 
                             '-a greedy ', 
                             '-e 5 ', 
                             '-m 12 ', 
                             '-s 70 ',  
                             '-i ',newPath,   
                            ' -o /bio/leandro_academico/samples/MG_34_Emma/postdata/Annotation_kaiju/MG_34_protein_newblwe_FINAL.name.out'))
    sink()
    
    comand <- paste0("qsub ",tempfile)
    system(comand)
    file$datapath <- newPath
    output$datasetChosen <- reactive({ TRUE })
    updateTabsetPanel(session, "mainNav", "settingsTab")
  })
})

# load the fasta file
observeEvent(input$loadSampleBtn, {
  withBusyIndicator("loadSampleBtn", {
    ##aqui

    updateTabsetPanel(session, "mainNav", "settingsTab")
  })
})

observe({
  req(input$uploadKaijuFiles)
  dataTableFiles$kaiju <- 1
})

observe({
  req(input$uploadKAASFiles)
  dataTableFiles$kaas <- 1
})

observe({
  req(input$uploadProteomicFiles)
  dataTableFiles$proteomic <- 1
})

observe({
  req(input$uploadInterProFiles)
  dataTableFiles$interPro <- 1
})

observe({
  req(input$uploadBlastFile)
  dataTableFiles$blast <- 1
})

observe({
  req(input$uploadMetaFile)
  dataTableFiles$meta <- 1
})


observeEvent(input$resetUploadFiles, {
  shinyjs::reset("uploadKaijuFiles")  # reset is a shinyjs function
  shinyjs::reset("uploadKAASFiles")
  shinyjs::reset("uploadProteomicFiles")
  shinyjs::reset("uploadInterProFiles")
  shinyjs::reset("uploadBlastFile")
  shinyjs::reset("uploadMetaFile")
  dataTableFiles$kaiju <- 0
  dataTableFiles$kaas <- 0
  dataTableFiles$proteomic <- 0
  dataTableFiles$interPro <- 0
  dataTableFiles$blast <- 0
  dataTableFiles$meta <- 0
  
  #input$uploadKaijuFiles <- 'reset'
  #input$uploadKaijuFiles$datapath <- 'reset'
  #input$uploadKAASFiles <- NULL
  #input$uploadProteomicFiles <- NULL
  #input$uploadInterProFiles <- NULL
  #input$uploadBlastFile <- NULL
  #input$uploadMetaFile <- NULL
  
  dataTableFiles$table = NULL
  dataTableFiles$table
})

# download kaiju data file
output$kaijuDataFile <- downloadHandler(
  filename = function() { "example_kaiju.names" },
  content = function(file) {
    file.copy(from = "/home/leandro/Git/mgcomp/files/kaiju.names", to = file, overwrite = TRUE)
  }
)

# download kaas data file
output$kaasResultsFile <- downloadHandler(
  filename = function() { "example_kaas.kaas" },
  content = function(file) {
    file.copy(from = "/home/leandro/Git/mgcomp/files/kaas.kaas", to = file, overwrite = TRUE)
  }
)

# download proteomic data file
output$proteomicResultsFile <- downloadHandler(
  filename = function() { "example_proteomic.fasta" },
  content = function(file) {
    file.copy(from = "/home/leandro/Git/mgcomp/files/proteomic.fasta", to = file, overwrite = TRUE)
  }
)

# download interPro data file
output$interProResultsFile <- downloadHandler(
  filename = function() { "example_interpro.tsv" },
  content = function(file) {
    file.copy(from = "/home/leandro/Git/mgcomp/files/interpro.tsv", to = file, overwrite = TRUE)
  }
)

# download blast data file
output$blastResultsFile <- downloadHandler(
  filename = function() { "example_blast.out" },
  content = function(file) {
    file.copy(from = "/home/leandro/Git/mgcomp/files/blast.out", to = file, overwrite = TRUE)
  }
)

# download metadata data file
output$metadataResultsFile <- downloadHandler(
  filename = function() { "example_metadata.csv" },
  content = function(file) {
    file.copy(from = "/home/leandro/Git/mgcomp/files/metadata.csv", to = file, overwrite = TRUE)
  }
)