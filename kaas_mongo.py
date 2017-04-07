# Author: Leandro Correa
# Date: 14.03.2017

import pandas as pd
import sys
import os
import datetime
import insert_metadata as metadata

from pymongo import MongoClient

# PATH_kaas = '/home/leandro/Data/metagenomas/MG_34_Emma/kaas/MG_34_Emma_ko_aa.txt'
# type_seq = 'contig'
# date = '21.03.2017'
# sample = 'MG_34'

time_init = datetime.datetime.now()
time_init_2 = datetime.datetime.now()
print_time = False

args = sys.argv

if '--help' in args:
    os.system('clear')
    print 'Script: Insert a kaas output into the Mongo metagenomic database.'
    print 'Author: Leandro Correa - @hscleandro'
    print 'Date: 14.03.2017\n'
    print 'How to use: python kaas_mongo.py -i INPUT_KAAS'
    print 'INPUT_KAAS [required]: File containing the kaas output in .csv format file Containing two fields in the table header:'
    print '1- Sequence ID'
    print '2- Ko familie\n\n'
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
        PATH_kaas = args[args.index('-i') + 1]
        split = str.split(PATH_kaas, '/')
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

            columns = ['read_id',
                       'ko'
                       ]

            kaas_df = pd.read_csv(PATH_kaas, sep="\t", names=columns)
            metadata_df = pd.read_csv(PATH_metadata, sep=",")

            data = {}

            for i in range(0, len(metadata_df.index)):
                key = metadata_df.iloc[i]['index']
                kwargs = metadata_df.iloc[i]['Requirement']
                data[key] = kwargs

            sample = data.get('sample_name')
            update = metadata.mongo_insert(PATH_metadata)

            # i = 2
            for i in range(0, len(kaas_df.index)):
                sequence_split = str.split(kaas_df.iloc[i]['read_id'], "_")
                read_id = kaas_df.iloc[i]['read_id']
                ko = kaas_df.iloc[i]['ko']

                update = collection.update({'id_seq': read_id},
                                           {'$set': {'kegg_ko': str(ko),
                                                     },
                                           }, upsert=False)

                if not update.get('updatedExisting'):
                    item = {'id_sample': sample,
                            'id_seq': read_id,
                            'kegg_ko': str(ko)
                            }
                    ObjectId = collection.insert(item)

                if i % 1000 == 0 and print_time:
                    time_end = datetime.datetime.now()
                    time = time_end - time_init_2
                    print str(i) + ' ' + read_id + "  time: " + str(time)
                    time_init_2 = time_end
        else:
            print '\nMetadata.csv file not found.'
            sys.exit('Use -m to set the metadata adress file or write python kaiju_mongo.py --help, for details.')
    else:
        sys.exit(
            "\n\nErro: Parameter -i required for script execution. \n\nUse: python kaiju_mongo.py --help for details.\n"
        )

    print "\n\nThe data was successfully stored."

if print_time:
    time_end = datetime.datetime.now()
    time = time_end - time_init
    print "total time: " + str(time)