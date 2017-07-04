# Author: Leandro Correa
# Date: 29.03.2017

import pandas as pd
import sys
import os
import parser_blast as parser
from progressbar.progressbar import *

from pymongo import MongoClient

args = sys.argv

# PATH_blast = '/home/leandro/Data/metagenomas/MG_34_Emma/blast/MG_34_FASTA_CDS_EMG_annotated.fasta.out'
# PATH_metadata = '/home/leandro/Data/metagenomas/MG_34_Emma/blast/metadata.csv'

if '--help' in args:
    os.system('clear')
    print 'Script: Insert a blast .csv output from into the Mongo metagenomic database.'
    print 'Author: Leandro Correa - @hscleandro'
    print 'Date: 29.03.2017\n'
    print 'How to use: python blast_mongo.py -i INPUT_BLAST.OUT -s SAMPLE -p PROJECT -time\n'
    print 'SAMPLE [required]: Sample name.'
    print 'PROJECT [required]: Project name.'
    print "INPUT_BLAST.OUT [required]: File containing the .out of Blast tool."
    print 'time: Graph indicating the total and expected completion time of the execution.\n\n'
    sys.exit('')

else:
    if '-i' in args:
        PATH_blast = args[args.index('-i') + 1]

        split = str.split(PATH_blast, '/')
        PATH = ''
        for s in range(1, len(split[:-1])):
            PATH = PATH + '/' + split[s]
        PATH += '/'
    else:
        sys.exit(
            "\n\nErro: Parameter -i required for script execution. \n\nUse: python blast_mongo.py --help for details.\n"
        )
    if '-s' in args:
        sample = args[args.index('-s') + 1]
    else:
        sys.exit(
            "\n\nErro: Parameter -s required for script execution. \n\nUse: python blast_mongo.py --help for details.\n"
        )
    if '-p' in args:
        project = args[args.index('-p') + 1]
    else:
        sys.exit(
            "\n\nErro: Parameter -p required for script execution. \n\nUse: python blast_mongo.py --help for details.\n"
        )
    if '-time' in args:
        print_time = True
    else:
        print_time = False

    client = MongoClient('localhost', 7755)
    db = client.local
    collection = db.sequences
    collection_sample = db.samples

    if print_time:
        print '\nLoading. . .\n'
        widgets = ['Update: ', Percentage(), ' ', Bar(marker=RotatingMarker()), ' ', ETA(), ' ',
                   FileTransferSpeed()]

    blast_tool = "loading"
    update = collection_sample.update({"$and":
        [{
            "sample_name": sample,
            "project": project,
        }]},
        {"$set": {"blast_tool": blast_tool}
         }, upsert=False)
    
    matrix = parser.parser_blast(PATH_blast)
    collums =["Query", "Sequence", "Score", "eValue"]
    blast_df = pd.DataFrame(matrix, columns=collums)

    if print_time:
        print str(len(blast_df.index)) + ' instances to be inserted in the mongo database.\n\n'

        pbar = ProgressBar(widgets=widgets, maxval=len(blast_df.index) * 1000).start()


    if not update.get('updatedExisting'):
        item = {'sample_name': sample.upper(),
                'project': project.upper(),
                'blast_tool': blast_tool
                }
        collection_sample.insert(item)

    # i = 10
    for i in range(1, len(blast_df.index)):
        read_id = blast_df.iloc[i]['Query']
        read_id = read_id.replace(" ", "")
        wide_sequence = blast_df.iloc[i]['Sequence']
        temp = str.split(wide_sequence, "|")
        sequence = temp[2]
        id_Sequence = str(temp[0]) + "|" + str(temp[1]) + "|"
        score = wide_sequence = blast_df.iloc[i]['Score']
        evalue = wide_sequence = blast_df.iloc[i]['eValue']

        update = collection.update({'id_seq': read_id, 'project': project, 'id_sample': sample},
                                   {'$set': {'blast_id': id_Sequence,
                                             'blast_hit': str(sequence),
                                             'blast_score': str(score),
                                             'blast_evalue': str(evalue)
                                             },
                                    }, upsert=False)

        if not update.get('updatedExisting'):
            item = ({'id_sample': sample.upper(),
                     'id_seq': read_id,
                     'project': project.upper(),
                     'sequence': str(sequence),
                     'blast_id': id_Sequence,
                     'blast_hit': str(sequence),
                     'blast_score': str(score),
                     'blast_evalue': str(evalue)
                    })

            ObjectId = collection.insert(item)
        if print_time:
            pbar.update(1000 * i + 1)
    if print_time:
        pbar.finish()

    blast_tool = "OK"
    update = collection_sample.update({"$and":
        [{
            "sample_name": sample,
            "project": project,
        }]},
        {"$set": {"blast_tool": blast_tool}
         }, upsert=False)

print "\n\nThe data was successfully stored."