# Author: Leandro Correa
# Date: 08.03.2017

import pandas as pd
import sys
import os
import datetime

from pymongo import MongoClient

time_init = datetime.datetime.now()
time_init_2 = datetime.datetime.now()
args = sys.argv
print_time = False

# PATH_emg = '/home/leandro/Data/metagenomas/MG_34_Emma/mgp/454ALLCONTIGS_FASTA_I5.tsv'
# sample = 'MG_34'
# type_seq = 'contig'
# date = '08.03.2017'

if '--help' in args:
    os.system('clear')
    print 'Script: Insert a .tsv output from EMG pipeline into the Mongo metagenomic database.'
    print 'Author: Leandro Correa - @hscleandro'
    print 'Date: 08.03.2017\n'
    print 'How to use: python emg_mongo.py -i INPUT_EMG.TSV -s SAMPLE_NAME -t TYPE_OF_SEQUENCE -d DATE_OF_ANALYSIS -time\n'
    print 'INPUT_EMG.TSV [required]: File containing the .tsv table of EMG pipeline.'
    print 'SAMPLE_NAME: Name of sample.'
    print 'TYPE_OF_SEQUENCE: Type of sequence (read, contig, scafold).'
    print 'DATE_OF_ANALYSIS: Date of tool execution.'
    print '-time [optional]: Details the execution time of the sample.'
    sys.exit('\nInput file format: The .tsv file must contain 15 fields, '
             'for more details go to: https://github.com/ebi-pf-team/interproscan/wiki/InterProScan5OutputFormats.')

else:
    if '-i' in args:
        PATH_emg = args[args.index('-i') + 1]

        if '-s' in args:
            sample = args[args.index('-s') + 1]
        else:
            sample = 'null'
        if '-t' in args:
            type_seq = args[args.index('-t') + 1]
        else:
            type_seq = 'null'
        if '-d' in args:
            date = args[args.index('-d') + 1]
        else:
            date = 'null'
        if '-time' in args:
            print_time = True

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
            if sample != 'null' and type_seq != 'null' and date != 'null':
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
                             'type_of_seq': type_seq,
                             'date': date,
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
            else:
                print 'Please enter the fields: date, ' \
                      'type of sequence and name of the sample.\n'
                print "Use: python kaiju_mongo.py --help for details."
                break

            if i % 1000 == 0 and print_time:
                time_end = datetime.datetime.now()
                time = time_end - time_init_2
                print str(i) + ' ' + read_id + "  time: " + str(time)
                time_init_2 = time_end
    else:
        sys.exit(
            "\n\nErro: Parameter -i required for script execution. \n\nUse: python emg_mongo.py --help for details.\n")

    print "\n\nThe data was successfully stored."

if print_time:
    time_end = datetime.datetime.now()
    time = time_end - time_init
    print "time: " + str(time)