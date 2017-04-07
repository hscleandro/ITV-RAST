# Author: Leandro Correa
# Date: 08.03.2017

import pandas as pd
import sys
import os
import datetime
import insert_metadata as metadata

from pymongo import MongoClient

time_init = datetime.datetime.now()
time_init_2 = datetime.datetime.now()
args = sys.argv
print_time = False

# PATH_emg = '/home/leandro/Data/metagenomas/MG_34_Emma/mgp/454ALLCONTIGS_FASTA_I5.tsv'

if '--help' in args:
    os.system('clear')
    print 'Script: Insert a .tsv output from EMG pipeline into the Mongo metagenomic database.'
    print 'Author: Leandro Correa - @hscleandro'
    print 'Date: 08.03.2017\n'
    print 'How to use: python interpro_mongo.py -i INPUT_EMG.TSV\n'
    print 'INPUT_EMG.TSV [required]: File containing the .tsv table of EMG pipeline. The .tsv file must contain 15 fields.\n' \
          'For more details go to: https://github.com/ebi-pf-team/interproscan/wiki/InterProScan5OutputFormats.\n\n'

    print 'IMPORTANT: Input file must be accompanied (in the same directory) from a .csv file called "metadata.csv". '\
          'The metadata.csv file must contain two columns titled: index and Requirement, as in the example:\n'

    print '+-----------------------------------+\n'\
          '|     index        |  Requirement   |\n'\
          '+------------------+----------------+\n'\
          '|   sample_name    |    AM001       |\n'\
          '+------------------+----------------+\n'\
          '|   type_sequence  |    contig      |\n'\
          '+------------------+----------------+\n'\
          '|   project        |    XPTO        |\n'\
          '+------------------+----------------+\n'

    sys.exit('The fields: sample_name, type_sequence and project are required, followed by other metadata that make up the sample.')
else:
    if '-i' in args:
        PATH_emg = args[args.index('-i') + 1]
        split = str.split(PATH_emg, '/')
        PATH = ''
        for s in range(1, len(split[:-1])):
            PATH = PATH + '/' + split[s]
        PATH += '/'

        directorie = os.listdir(PATH)
        if 'metadata.csv' in directorie or '-m' in args:
            if '-time' in args:
                print_time = True
            if '-m' in args:
                PATH_metadata = args[args.index('-m') + 1]
            else:
                PATH_metadata = PATH + 'metadata.csv'

            client = MongoClient('localhost', 7755)
            db = client.local
            collection = db.sequences

            columns = ['Protein Accession',  # 1
                       'Sequence MD5 digest',  # 2
                       'Sequence Length',  # 3
                       'Analysis',  # 4
                       'Signature Accession',  # 5
                       'Signature Description',  # 6
                       'Start location',  # 7
                       'Stop location',  # 8
                       'Score',  # 9
                       'Status',  # 10
                       'Date',  # 11
                       'InterPro accession',  # 12
                       'InterPro description',  # 13
                       'GO annotations',  # 14
                       'Pathways annotations']  # 15

            emg_df = pd.read_csv(PATH_emg, sep="\t", names=columns)
            metadata_df = pd.read_csv(PATH_metadata, sep=",")

            data = {}

            for i in range(0, len(metadata_df.index)):
                key = metadata_df.iloc[i]['index']
                kwargs = metadata_df.iloc[i]['Requirement']
                data[key] = kwargs

            sample = data.get('sample_name')
            update = metadata.mongo_insert(PATH_metadata)

            # i = 10
            for i in range(0, len(emg_df.index)):
                read_id = emg_df.iloc[i]['Protein Accession']
                sequence = str.split(emg_df.iloc[i]['Protein Accession'], "_")[0]
                start_frame = str.split(emg_df.iloc[i]['Protein Accession'], "_")[1]
                stop_frame = str.split(emg_df.iloc[i]['Protein Accession'], "_")[2]
                sense_frame = str.split(emg_df.iloc[i]['Protein Accession'], "_")[3]
                start_location = emg_df.iloc[i]['Start location']
                stop_location = emg_df.iloc[i]['Stop location']
                signature_accession = emg_df.iloc[i]['Signature Accession']
                signature_description = emg_df.iloc[i]['Signature Description']
                protein_analysis = emg_df.iloc[i]['Analysis']
                Score = emg_df.iloc[i]['Score']
                interpro_accession = emg_df.iloc[i]['InterPro accession']
                interpro_description = emg_df.iloc[i]['InterPro description']

                if type(emg_df.iloc[i]['GO annotations']) is str:
                    go_annotations = str.split(emg_df.iloc[i]['GO annotations'], "|")
                else:
                    go_annotations = []

                Kegg_Pathways = []
                Metacyc_pathways = []
                Reactome_pathways = []

                if type(emg_df.iloc[i]['Pathways annotations']) is str:

                    pathways_annotations = str.split(emg_df.iloc[i]['Pathways annotations'], "|")

                    for j in range(0, len(pathways_annotations)):
                        if pathways_annotations[j].find('KEGG') == 0:
                            Kegg_Pathways.append(pathways_annotations[j])
                        else:
                            if pathways_annotations[j].find('MetaCyc') == 0:
                                Metacyc_pathways.append(pathways_annotations[j])
                            else:
                                if pathways_annotations[j].find('Reactome') == 0:
                                    Reactome_pathways.append(pathways_annotations[j])
                update = collection.update({"id_seq": read_id},
                                           {"$addToSet": {"orfs_inf":
                                                          [{
                                                            "start_location": str(start_location),
                                                            "stop_location": str(stop_location),
                                                            "signature_accession": str(signature_accession),
                                                            "signature_description": str(signature_description),
                                                            "protein_analysis": str(protein_analysis),
                                                            "score": str(Score),
                                                            "interpro_accession": str(interpro_accession),
                                                            "interpro_description": str(interpro_description),
                                                            "protem_seq": "",
                                                            "go_annotations": str(go_annotations),
                                                            "kegg_Pathways": Kegg_Pathways,
                                                            "reactome_pathways": Reactome_pathways,
                                                            "metacyc_pathways": Metacyc_pathways
                                                          }],
                                                         }
                                           }, upsert=False)

                if not update.get('updatedExisting'):
                    item = ({'id_sample': sample,
                             'id_seq': read_id,
                             'sequence': str(sequence),
                             'orfs_inf':
                                     [{
                                       "start_location": str(start_location),
                                       "stop_location": str(stop_location),
                                       "signature_accession": str(signature_accession),
                                       "signature_description": str(signature_description),
                                       "protein_analysis": str(protein_analysis),
                                       "score": str(Score),
                                       "interpro_accession": str(interpro_accession),
                                       "interpro_description": str(interpro_description),
                                       "protem_seq": "",
                                       "go_annotations": str(go_annotations),
                                       "kegg_Pathways": Kegg_Pathways,
                                       "reactome_pathways": Reactome_pathways,
                                       "metacyc_pathways": Metacyc_pathways
                                     }],
                            })

                    ObjectId = collection.insert(item)

                if i % 1000 == 0 and print_time:
                    time_end = datetime.datetime.now()
                    time = time_end - time_init_2
                    print str(i) + ' ' + read_id + "  time: " + str(time)

                    time_init_2 = time_end
        else:
            print '\nMetadata.csv file not found.'
            sys.exit('Use -m to set the metadata adress file or write python interpro_mongo.py --help, for details.')

    if not '-i' in args:
        sys.exit("\nErro: Parameter -i required for script execution. \n\nUse python interpro_mongo.py --help for details.\n")

print "\n\nThe data was successfully stored."

if print_time:
    time_end = datetime.datetime.now()
    time = time_end - time_init
    print "time: " + str(time)
