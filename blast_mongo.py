# Author: Leandro Correa
# Date: 29.03.2017

import pandas as pd
import sys
import os
import datetime
import parser_blast as parser
import insert_metadata as metadata
from progressbar.progressbar import *

from pymongo import MongoClient

args = sys.argv

# PATH_blast = '/home/leandro/Python/metagenomics-database/input/blast.out'

if '--help' in args:
    os.system('clear')
    print 'Script: Insert a blast .csv output from into the Mongo metagenomic database.'
    print 'Author: Leandro Correa - @hscleandro'
    print 'Date: 29.03.2017\n'
    print 'How to use: python blast_mongo.py -i INPUT_BLAST.OUT\n'
    print "INPUT_BLAST.OUT [required]: File containing the .out of Blast tool.\n\n"

    print 'IMPORTANT: Input file must be accompanied (in the same directory) from a .csv file called "metadata.csv". ' \
          'The metadata.csv file must contain two columns titled: index and Requirement, as in the example:\n'

    print '+-----------------------------------+\n' \
          '|     index        |  Requirement   |\n' \
          '+------------------+----------------+\n' \
          '|   sample_name    |    AM001       |\n' \
          '+------------------+----------------+\n' \
          '|   type_sequence  |    contig      |\n' \
          '+------------------+----------------+\n' \
          '|   project        |    XPTO        |\n' \
          '+------------------+----------------+\n'

    sys.exit(
        'The fields: sample_name, type_sequence and project are required, followed by other metadata that make up the sample.')

else:
    if '-i' in args:
        PATH_blast = args[args.index('-i') + 1]

        split = str.split(PATH_blast, '/')
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

            if '-time' in args:
                print_time = True

            client = MongoClient('localhost', 7755)
            db = client.local
            collection = db.sequences

            print '\nLoading. . .\n'
            widgets = ['Update: ', Percentage(), ' ', Bar(marker=RotatingMarker()), ' ', ETA(), ' ',
                       FileTransferSpeed()]

            matrix = parser.parser_blast(PATH_blast)
            blast_df = pd.DataFrame(matrix)
            print str(len(blast_df.index)) + ' instances to be inserted in the mongo database.\n\n'

            metadata_df = pd.read_csv(PATH_metadata, sep=",")
            pbar = ProgressBar(widgets=widgets, maxval=len(blast_df.index) * 1000).start()

            data = {}

            for i in range(0, len(metadata_df.index)):
                key = metadata_df.iloc[i]['index']
                kwargs = metadata_df.iloc[i]['Requirement']
                data[key] = kwargs

            sample = data.get('sample_name')
            update = metadata.mongo_insert(PATH_metadata)

            # i = 10
            for i in range(0, len(blast_df.index)):
                read_id = blast_df.iloc[i]['Query']
                wide_sequence = blast_df.iloc[i]['Sequence']
                temp = str.split(wide_sequence, "|")
                sequence = temp[2]
                id_Sequence = str(temp[0]) + "|" + str(temp[1]) + "|"
                score = wide_sequence = blast_df.iloc[i]['Score']
                evalue = wide_sequence = blast_df.iloc[i]['eValue']

                update = collection.update({'id_seq': read_id},
                                           {'$set': {'blast_id': id_Sequence,
                                                     'blast_hit': str(sequence),
                                                     'blast_score': str(score),
                                                     'blast_evalue': str(evalue)
                                                     },
                                            }, upsert=False)

                if not update.get('updatedExisting'):
                    item = ({'id_sample': sample,
                             'id_seq': read_id,
                             'sequence': str(sequence),
                             'blast_id': id_Sequence,
                             'blast_hit': str(sequence),
                             'blast_score': str(score),
                             'blast_evalue': str(evalue)
                            })

                    ObjectId = collection.insert(item)
                pbar.update(1000 * i + 1)
            pbar.finish()
        else:
            print '\nMetadata.csv file not found.'
            sys.exit('Use -m to set the metadata adress file or write python blast_mongo.py --help, for details.')
    else:
        sys.exit(
            "\n\nErro: Parameter -i required for script execution. \n\nUse: python blast_mongo.py --help for details.\n")

    print "\n\nThe data was successfully stored."