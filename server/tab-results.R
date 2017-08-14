#library(grid)
library(scales)
library(pvclust)
#library(dendextend) 
#sample <- "MG34_MGRAST_N"
#project <- "CANGA"

#data <- data.frame(
#  Sample = c("MG34_MGRAST_N","AM1","V1","V2","LTI11","LTI21","LTI31"),
#  Project = c("CANGA","LAKES","LAKES","LAKES","LAKES","LAKES","LAKES")
#)

#data <- find_taxons("JCVI","AM1")

taxon_filter <- function(taxon_inf){
  if(input$taxon_list == "Domain"){
    taxon <- "kingdom"
  }
  else if(input$taxon_list == "Phylum"){
    taxon <- "phylum"
  }
  else if(input$taxon_list == "Class"){
    taxon <- "class"
  }
  else if(input$taxon_list == "Order"){
    taxon <- "order"
  }
  else if(input$taxon_list == "Family"){
    taxon <- "family"
  }
  
  index_selected_taxons <- which(taxon_inf[,taxon] == input$name_list)
  taxon_inf <- taxon_inf[index_selected_taxons,]
  
  return(taxon_inf)
}

get_taxonList <- function(taxon_input, flag = FALSE){
  data <- as.data.frame(dataTableFiles$bd_one)
  k <- 1; l_df <- list(); names_taxons <- NULL
  for(i in 1:nrow(data)){
    project <- data$Project[i]
    sample <- data$Sample[i]
    #project <- "LAKES"
    #sample <-  "AM1"
    taxon_inf <- find_taxons(project,sample)
    
    if(flag == TRUE){ taxon_inf <- taxon_filter(taxon_inf) }
    else{
      
      dataTableFiles$taxons_inf$species <- c(dataTableFiles$taxons_inf$species, unique(taxon_inf$species))
      dataTableFiles$taxons_inf$species <- unique(dataTableFiles$taxons_inf$species)
      
      dataTableFiles$taxons_inf$genre <- c(dataTableFiles$taxons_inf$genre, unique(taxon_inf$genre))
      dataTableFiles$taxons_inf$genre <- unique(dataTableFiles$taxons_inf$genre)
      
      dataTableFiles$taxons_inf$family <- c(dataTableFiles$taxons_inf$family, unique(taxon_inf$family))
      dataTableFiles$taxons_inf$family <- unique(dataTableFiles$taxons_inf$family)
      
      dataTableFiles$taxons_inf$order <- c(dataTableFiles$taxons_inf$order, unique(taxon_inf$order))
      dataTableFiles$taxons_inf$order <- unique(dataTableFiles$taxons_inf$order)
      
      dataTableFiles$taxons_inf$class <- c(dataTableFiles$taxons_inf$class, unique(taxon_inf$class))
      dataTableFiles$taxons_inf$class <- unique(dataTableFiles$taxons_inf$class)
      
      dataTableFiles$taxons_inf$phylum <- c(dataTableFiles$taxons_inf$phylum, unique(taxon_inf$phylum))
      dataTableFiles$taxons_inf$phylum <- unique(dataTableFiles$taxons_inf$phylum)
      
      dataTableFiles$taxons_inf$kingdom <- c(dataTableFiles$taxons_inf$kingdom, unique(taxon_inf$kingdom))
      dataTableFiles$taxons_inf$kingdom <- unique(dataTableFiles$taxons_inf$kingdom)
      
    }
    
    if(taxon_input == "Domain"){
      sample_summary <- taxon_inf %>%
        group_by(kingdom) %>%
        select(kingdom) %>%
        summarise(freqSequence = n())
    }
    else if(taxon_input == "Phylum"){
      sample_summary <- taxon_inf %>%
        group_by(phylum) %>%
        select(phylum) %>%
        summarise(freqSequence = n())
    }
    else if(taxon_input == "Class"){
      sample_summary <- taxon_inf %>%
        group_by(class) %>%
        select(class) %>%
        summarise(freqSequence = n())
    }
    else if(taxon_input == "Order"){
      sample_summary <- taxon_inf %>%
        group_by(order) %>%
        select(order) %>%
        summarise(freqSequence = n())
    }
    else if(taxon_input == "Family"){
      sample_summary <- taxon_inf %>%
        group_by(family) %>%
        select(family) %>%
        summarise(freqSequence = n())
    }
    else if(taxon_input == "Genus"){
      sample_summary <- taxon_inf %>%
        group_by(genre) %>%
        select(genre) %>%
        summarise(freqSequence = n())
    }
    else if(taxon_input == "Species"){
      sample_summary <- taxon_inf %>%
        group_by(species) %>%
        select(species) %>%
        summarise(freqSequence = n())
    }
    colnames(sample_summary) <- c("taxon","frequence")
    
    #i <- which(sample_summary$taxon == "NA")
    #sample_summary <- sample_summary[-i,]
    
    names_taxons[k] <- paste0(project,"-",sample)
    
    l_df[[k]] <- sample_summary
    k <- k +1
  }
  
  taxons <- Reduce(function(dtf1,dtf2) full_join(dtf1,dtf2,by="taxon"), l_df)
  names_taxons <- c("taxon",names_taxons)
  colnames(taxons) <- names_taxons
  taxons[is.na(taxons)==TRUE] <- 0
  
  sum <- apply(taxons[,-1], 1, sum)
  ord <- order(sum, decreasing = T)
  taxons <- taxons[ord,]
  index_na <- which(taxons$taxon == "NA")
  taxons <- taxons[-index_na,]
  
  return(taxons)
}

filter_name <- function(){
  if(input$taxon_list == "Domain"){
    list_txon <- dataTableFiles$taxons_inf$kingdom
    #taxon <- "kingdom"
  }
  else if(input$taxon_list == "Phylum"){
    list_txon <- dataTableFiles$taxons_inf$phylum
    #taxon <- "phylum"
  }
  else if(input$taxon_list == "Class"){
    list_txon <- dataTableFiles$taxons_inf$class
    #taxon <- "class"
  }
  else if(input$taxon_list == "Order"){
    list_txon <- dataTableFiles$taxons_inf$order
    #taxon <- "order"
  }
  else if(input$taxon_list == "Family"){
    list_txon <- dataTableFiles$taxons_inf$family
    #taxon <- "family"
  }
  #data <- dataTableFiles$taxons
  #list_txon <- unique(data[,'taxon'])  
  index_na <- which(list_txon == "NA")
  list_txon <- list_txon[-index_na]
  
  return(list_txon)
}

output$list_taxon <- renderUI({
  
  selectInput(inputId = "taxon_list", 
              label = "",
              choices = c("Domain","Phylum","Class","Order","Family")
  )
})

output$list_name <- renderUI({
  list_txon <- filter_name()
  selectInput(inputId = "name_list", 
              label = "",
              choices = list_txon
  )
})

output$list_analytics <- renderUI({
  
  selectInput(inputId = "analytics_list", 
              label = "",
              choices = c("Domain","Phylum","Class","Order","Family","Genus","Species")
  )
})

output$range_taxon <- renderUI({
  #p.fisica <- cDatRaw$Captacao[which(cDatRaw$Tipo.de.Pessoa == "FÍSICA")]
  sliderInput("r_taxon", 
              label = "Top scores",
              min = 0, 
              max = 50,
              value = 50,
              step = 10)
})

output$value <- renderText({ numbers() })

numbers <- reactive({
  validate(
    need(is.numeric(input$obs), "Please input a number")
  )
})

observeEvent(input$analyzeBtn, {
  
  taxons <- get_taxonList("Domain")
  output$analysis <- reactive({ TRUE })
  dataTableFiles$taxons <- taxons
  
  output$plot_taxons <- renderPlot({
    
    top <- 50
    data <- dataTableFiles$taxons
    data <- data[1:top,]
    medata <- melt(data)
    
    cols <- colorRampPalette(brewer.pal(8, "Accent"))
    myPal <- cols(length(unique(data$taxon)))
    
    ggplot(medata,aes(x = variable, y = value,fill = taxon)) + 
      geom_bar(position = "fill",stat = "identity") + coord_flip() +
      scale_fill_manual(values = myPal) +
      scale_y_continuous(labels = percent_format())
    
  })
  
})

observeEvent(input$Submit_tax, {
  type_taxon <- input$analytics_list
  #if(type_taxon == "domain") {type_taxon <- "kingdom"}
  
  taxons <- get_taxonList(type_taxon, TRUE)
  dataTableFiles$taxons <- taxons
  
  top <- input$r_taxon 
  
  output$plot_taxons <- renderPlot({
  
    data <- dataTableFiles$taxons
    data <- data[1:top,]
    medata <- melt(data)
    
    cols <- colorRampPalette(brewer.pal(8, "Accent"))
    myPal <- cols(length(unique(data$taxon)))
    
    ggplot(medata,aes(x = variable, y = value,fill = taxon)) + 
      geom_bar(position = "fill",stat = "identity") + coord_flip() +
      scale_fill_manual(values = myPal) +
      scale_y_continuous(labels = percent_format())
    
  })
 
  
})

observeEvent(input$Submit_est, {
  
  top <- 25 
  data <- dataTableFiles$taxons
  data <- data[1:top,]
  
  taxon_matrix <- data[,-1]
  taxon_matrix  <- as.matrix(taxon_matrix)
  
  
  result <- pvclust(as.matrix(taxon_matrix),
                    method.dist = input$distance_metric, 
                    method.hclust= input$linkage_algorithm, nboot = input$obs)
  
  output$plot_dendo <- renderPlot({
    
    plot(result,
         main="Phyla top 30"
    )
    pvrect(result, alpha = input$alfa)
    
  })
  
})

output$resultTableDB = DT::renderDataTable({
  data <- taxons
  data <- dataTableFiles$taxons
  DT::datatable(
    data, escape = FALSE, selection = 'single', extensions = 'Responsive', 
    rownames= FALSE
    #   options = list(
    #    preDrawCallback = JS('function() { Shiny.unbindAll(this.api().table().node()); }'),
    #    drawCallback = JS('function() { Shiny.bindAll(this.api().table().node()); } ')
    # )
  )
})




