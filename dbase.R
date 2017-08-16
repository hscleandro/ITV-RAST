#input <- '/home/leandro/Data/metagenomas/Lagoas/tres_irmas/posdata/LTI11/LAKES-LTI11_kaiju_names.out'
#sample <- "LTI11"
#project <- "LAKES"
#tool <- "kaiju"
#insert_metegenomics_db(input,project,sample,tool)
sequence = mongo(collection = "sequences", db = "local", url = "mongodb://mongoDB-Metagenomics:27017",
                 verbose = FALSE, options = ssl_options())

insert_metegenomics_db <- function(input_path,project,sample,tool){
  input_scripts_database <- "/srv/shiny-server/itv-rast/metagenomics-database/"
  #sample <- "a1"
  #project <- "t1"
  #input_path <- '/home/leandro/Data/metagenomas/Lagoas/amendoim/posdata/AM1/LAKES-AM1_kaiju_names.out'
  if(tool == "kaiju")
  {
    comand <- paste0("/usr/bin/python2.7 ", input_scripts_database,"kaiju_mongo.py -i ", input_path," -s ", sample," -p ", project)
    #cat("comand kaiju: ",comand,"\n")
  
  }
  else if(tool == "kaas")
  {
    comand <- paste0("/usr/bin/python2.7 ", input_scripts_database,"kaas_mongo.py -i ", input_path," -s ", sample," -p ", project)
    
  }
  else if(tool == "interpro")
  {
    comand <- paste0("/usr/bin/python2.7 ", input_scripts_database,"interpro_mongo.py -i ", input_path," -s ", sample," -p ", project)
  
  }
  else if(tool == "blast")
  {
    comand <- paste0("/usr/bin/python2.7 ", input_scripts_database,"blast_mongo.py -i ", input_path," -s ", sample," -p ", project)
  
  }
  else if(tool == "proteomic")
  {
    comand <- paste0("/usr/bin/python2.7 ", input_scripts_database,"proteomic-hit_mongo.py -i ", input_path," -s ", sample," -p ", project)
    
  }
  else if(tool == "metadata")
  {
    comand <- paste0("/usr/bin/python2.7 ", input_scripts_database,"insert_metadata.py -i ", input_path," -s ", sample," -p ", project)
    
  }
  #system(command = "pip install pandas", wait = TRUE)
  system(command = comand, wait = FALSE)
  
}

remove_metegenomics_db <- function(project,sample,tool){
  input_scripts_database <- "/srv/shiny-server/itv-rast/metagenomics-database/"
  
  comand <- paste0("python ", input_scripts_database,"remove_items.py -s ", sample," -p ", project," -t ", tool)
  
  system(command = comand, wait = FALSE)
  
  
}

find_taxons <- function(project,sample){
  taxon_info <- sequence$find(paste0('{"$and": [{"id_taxon":{"$exists": "true"}, 
                                       "project":"',project,'",
                                       "id_sample":"',sample,'"}] }'),
                              field = paste0('{"id_seq" :"",
                                             "kingdom":"",
                                             "phylum":"",
                                             "class" : "",
                                             "order" : "",
                                             "family" : "",
                                             "genre" : "",
                                             "species" : ""}'),
                              limit = 2000
                              
  )             
  taxon_info <- taxon_info[,-1]
  return(taxon_info)
}

