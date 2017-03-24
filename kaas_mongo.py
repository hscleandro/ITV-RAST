# Author: Leandro Correa
# Date: 14.03.2017

import pandas as pd
import sys
import os
import datetime

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
    print 'How to use: python kaas_mongo.py -i INPUT_KAAS -s SAMPLE_NAME -t TYPE_OF_SEQUENCE -d DATE_OF_ANALYSIS -time\n'
    print 'INPUT_KAAS [required]: File containing the kaas output.'
    print 'SAMPLE_NAME [required]: Name of sample.'
    print 'TYPE_OF_SEQUENCE [required]: Type of sequence (read, contig, scafold).'
    print 'DATE_OF_ANALYSIS [required]: Date of tool execution.'
    print '-time [optional]: Details the execution time of the sample.'
    print '\nInput file format: The kaas output must contain 2 fields:'
    print '1- Sequence ID'
    sys.exit('2- Ko familie')

else:
    if '-i' in args:
        PATH_kaas = args[args.index('-i') + 1]

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

        columns = ['read_id',
                   'ko'
                   ]

        kaas_df = pd.read_csv(PATH_kaas, sep="\t", names=columns)

        # i = 2
        for i in range(0, len(kaas_df.index)):
            sequence_split = str.split(kaas_df.iloc[i]['read_id'], "_")
            read_id = kaas_df.iloc[i]['read_id']
            ko = kaas_df.iloc[i]['ko']
            if sample != 'null' and type_seq != 'null' and date != 'null':
                update = collection.update({'id_seq': read_id},
                                          {'$set': {'kegg_ko': str(ko),
                                                     },
                                           }, upsert=False)
                if not update.get('updatedExisting'):
                    item = {'id_sample': sample,
                            'id_seq': read_id,
                            'type_of_seq': type_seq,
                            'date': date,
                            'kegg_ko': str(ko)
                            }
                    ObjectId = collection.insert(item)
            else:
                print '\nPlease enter the fields: date, ' \
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
            "\n\nErro: Parameter -i required for script execution. \n\nUse: python kaiju_mongo.py --help for details.\n"
        )

    print "\n\nThe data was successfully stored."

if print_time:
    time_end = datetime.datetime.now()
    time = time_end - time_init
    print "total time: " + str(time)