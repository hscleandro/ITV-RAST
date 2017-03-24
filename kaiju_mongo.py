# Author: Leandro Correa
# Date: 08.03.2017

import pandas as pd
import sys
import os
import datetime

from pymongo import MongoClient

# PATH_kaiju = '/home/leandro/Data/metagenomas/MG_34_Emma/mgp/aqui/MG_34_filtered.kaiju3.names_taxon.out'
# type_seq = 'contig'
# date = '08.03.2017'
# sample = 'MG_34'

time_init = datetime.datetime.now()
time_init_2 = datetime.datetime.now()
args = sys.argv
print_time = False

if '--help' in args:
    os.system('clear')
    print 'Script: Insert a kaiju output into the Mongo metagenomic database.'
    print 'Author: Leandro Correa - @hscleandro'
    print 'Date: 09.03.2017\n'
    print 'How to use: python kaiju_mongo.py -i INPUT_KAIJU -s SAMPLE_NAME -t TYPE_OF_SEQUENCE -d DATE_OF_ANALYSIS -time\n'
    print 'INPUT_KAIJU [required]: File containing the kaiju output.'
    print 'SAMPLE_NAME [required]: Name of sample.'
    print 'TYPE_OF_SEQUENCE [required]: Type of sequence (read, contig, scafold).'
    print 'DATE_OF_ANALYSIS [required]: Date of tool execution.'
    print '-time [optional]: Details the execution time of the sample.'
    print '\nInput file format: The kaiju output must contain 4 fields:'
    print '1- Tag to indicate whether the sequence was annotated or not (U or C)'
    print '2- Sequence ID'
    print '3- Taxon ID'
    sys.exit('4- Taxon name')

else:
    if '-i' in args:
        PATH_kaiju = args[args.index('-i') + 1]

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

        columns = ['status',
                   'read_id',
                   'taxon_id',
                   'taxon_name']

        kaiju_df = pd.read_csv(PATH_kaiju, sep="\t", names=columns)
        erro = False
        # i = 0
        for i in range(0, len(kaiju_df.index)):
            read_id = kaiju_df.iloc[i]['read_id']
            sequence = str.split(read_id, "_")[0]
            id_taxon = kaiju_df.iloc[i]['taxon_id']
            name_taxon = kaiju_df.iloc[i]['taxon_name']
            if str(type(name_taxon)) == "<type 'str'>":
                taxons_hierarchy = str.split(name_taxon, ';')[0:7]
            else:
                taxons_hierarchy = ['NA', 'NA', 'NA', 'NA', 'NA', 'NA']

            if sample != 'null' and type_seq != 'null' and date != 'null':
                update = collection.update({'id_seq': read_id},
                                                   {'$set': {'id_taxon': str(id_taxon),
                                                             'kingdom': str(taxons_hierarchy[0]),
                                                             'phylum': str(taxons_hierarchy[1]),
                                                             'class': str(taxons_hierarchy[2]),
                                                             'order': str(taxons_hierarchy[3]),
                                                             'family': str(taxons_hierarchy[4]),
                                                             'genre': str(taxons_hierarchy[5]),
                                                             'species': str(taxons_hierarchy[5])
                                                             },
                                                    }, upsert=False)
                if not update.get('updatedExisting'):
                    item = {'id_sample': sample,
                            'id_seq': read_id,
                            'type_of_seq': type_seq,
                            'date': date,
                            'id_taxon': str(id_taxon),
                            'sequence': str(sequence),
                            'kingdom': str(taxons_hierarchy[0]),
                            'phylum': str(taxons_hierarchy[1]),
                            'class': str(taxons_hierarchy[2]),
                            'order': str(taxons_hierarchy[3]),
                            'family': str(taxons_hierarchy[4]),
                            'genre': str(taxons_hierarchy[5]),
                            'species': str(taxons_hierarchy[5])
                            }
                    ObjectId = collection.insert(item)
            else:
                erro = True
                print '\nPlease enter the fields: date, ' \
                                                    'type of sequence and name of the sample.\n'
                print "Use: python kaiju_mongo.py --help for details."
                break
            if i % 1000 == 0 and print_time:
                time_end = datetime.datetime.now()
                time = time_end - time_init_2
                print str(i) + ' ' + read_id + "\t  time: " + str(time)
                time_init_2 = time_end
    else:
        sys.exit(
            "\n\nErro: Parameter -i required for script execution. \n\nUse: python kaiju_mongo.py --help for details.\n"
        )

    if not erro:
        print "\n\nThe data was successfully stored."

if print_time:
    time_end = datetime.datetime.now()
    time = time_end - time_init
    print "total time: \t" + str(time)
