from pymongo import MongoClient
import pymongo as mongo
import os

address = os.getcwd()
collums = ["V1", "V2"]
config_address = address.replace('python_db','') + 'setup.conf'

config = pd.read_csv(config_address, sep="=", names=collums)

port = config.iloc[1]["V2"]
port = port.replace('"','')
port = port.replace(' ', '')
port = int(port)
host = config.iloc[0]["V2"]
host = host.replace('"', '')
host = host.replace(' ', '')

client = MongoClient(host, port)

db = client.local
collection = db.sequences
collection_samples = db.samples
collection_funn = db.funn

atributes = ["id_sample", "id_seq", "project", "sequence",
             #"orfs_inf",
             "stop_location", "signature_accession", "signature_description",
             "protein_analysis", "score", "interpro_descrip,tion", "protem_seq"
             "go_annotations", "kegg_Pathways", "reactome_pathways", "metacyc_pathways",
             "kegg_ko", "id_taxon", "kingdom", "phylum", "class", "order", "family",
             "genre", "blast_id", "blast_hit", "blast_score", "blast_evalue", "proteomics"]

for id in atributes:
    collection.ensure_index([(id, mongo.ASCENDING)])

atributes_sample = ["sample_name", "sequence", "date", "project", "latitude", "longitude"]

for id_sample in atributes_sample:
    collection_samples.ensure_index([(id_sample, mongo.ASCENDING)])

atributes_funn = ["sample_name", "sequence", "date", "project", "kegg_Pathways", "kegg_ko"]

for id_funn in atributes_funn:
    collection_funn.ensure_index([(id_funn, mongo.ASCENDING)])
