############################################################# instalation

# requeres to linux
# sudo apt-get install libssl-dev
# sudo apt-get install libcurl4-openssl-dev libxml2-dev

# installl packages
#install.packages("jsonlite")
#install.packages("vegan")
#install.packages("rsconnect", dependencies = TRUE)
#install.packages("PKI")
#install.packages("ddpcr")
#install.packages("rjson")

#####################################################################################################################

library(rsconnect) # for shinyapps.io #### necessary install.packages("devtools", dependencies = TRUE)
# install.packages("rmarkdown") ### 
library(shiny)
library(shinyjs)
library(ddpcr)
library(rmarkdown)
library(knitr)
library(vegan)
library(rjson)
library(jsonlite)
library(DT)
library(mongolite)

options( stringsAsFactors=F ) 

library(ggplot2)
library(reshape2)
library(scales)
#detach(package:plyr)    # to avoid having problems with dplyr
library(dplyr)
library(RColorBrewer)

source(file.path("ui", "helpers.R"))

samples = mongo(collection = "samples", db = "local", url = "mongodb://localhost:7755",
              verbose = FALSE, options = ssl_options())

tagList(
  useShinyjs(),
  tags$head(
    tags$script(src = "ddpcr.js"),
    tags$link(href = "style.css", rel = "stylesheet")
  ),
  div(id = "loading-content", "Loading...",
      img(src = "ajax-loader-bar.gif")),
  
  navbarPage(
    title=div(img(id = "logo-title", src="metacomparer3.png")),
    windowTitle = "ITV-Rast",
    id = "mainNav",
    inverse = TRUE,
    fluid = FALSE,
    collapsible = TRUE,
    header = source(file.path("ui", "header.R"),  local = TRUE)$value,
    
    # include the UI for each tab
    source(file.path("ui", "tab-dataset.R"),  local = TRUE)$value,
    source(file.path("ui", "tab-settings.R"), local = TRUE)$value,
    source(file.path("ui", "tab-analyze.R"),  local = TRUE)$value,
    source(file.path("ui", "tab-results.R"),  local = TRUE)$value,
    source(file.path("ui", "tab-about.R"),    local = TRUE)$value,
    
    footer = 
      column(12,
        hidden(
          div(id = "errorDiv",
            div(icon("exclamation-circle"),
                tags$b("Error: "),
                span(id = "errorMsg")
            )
          )
        )
      )
  )
)
