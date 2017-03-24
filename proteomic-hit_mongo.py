# Author: Leandro Correa
# Date: 14.03.2017

import sys
import os
import datetime
import re

from pymongo import MongoClient

# proteomic_file = '/home/leandro/Data/metagenomas/MG_34_Emma/hit_protein/Canga_hit_proteins.fasta'
# type_seq = 'contig'
# date = '08.03.2017'
# sample = 'MG_34'

time_init = datetime.datetime.now()
time_init_2 = datetime.datetime.now()
print_time = False

args = sys.argv

if '--help' in args:
    os.system('clear')
    print 'Script: Insert a proteomic table output into the Mongo metagenomic database.'
    print 'Author: Leandro Correa - @hscleandro'
    print 'Date: 14.03.2017\n'
    print 'How to use: python proteomic_mongo.py -i INPUT_TABLE -s SAMPLE_NAME -t TYPE_OF_SEQUENCE -d DATE_OF_ANALYSIS -time\n'
    print 'INPUT_TABLE [required]: File containing the result of proteomic analyse.'
    print 'SAMPLE_NAME [required]: Name of sample.'
    print 'TYPE_OF_SEQUENCE [required]: Type of sequence (read, contig, scafold).'
    print 'DATE_OF_ANALYSIS [required]: Date of tool execution.'
    print '-time [optional]: Details the execution time of the sample.'
    sys.exit(
        '\nInput file format: The proteomic output must be the fasta format contain the header and the aminoacids of each sequence.')

else:
    if '-i' in args:
        proteomic_file = args[args.index('-i') + 1]

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

        i = 1
        for line in open(proteomic_file, 'r'):
            if i % 2 == 1:
                # line = ">contig00001_32677_33900_+"
                read_id = line[1:]
                read_id = re.sub("\n", "", read_id)
                sequence = str.split(read_id, "_")[0]
                #"""
                if sample != 'null' and type_seq != 'null' and date != 'null':
                    update = collection.update({'id_seq': read_id},
                                               {'$set': {'proteomics': "true"
                                                          },
                                                }, upsert=False)
                    print read_id + "\t" + str(update.get('updatedExisting'))
                    if not update.get('updatedExisting'):
                        item = {'id_sample': sample,
                                'id_seq': read_id,
                                'type_of_seq': type_seq,
                                'date': date,
                                'sequence': sequence,
                                'proteomics': "true"
                                }
                        ObjectId = collection.insert(item)
                else:
                    erro = True
                    print '\nPlease enter the fields: date, ' \
                          'type of sequence and name of the sample.\n'
                    print "Use: python proteomic_mongo.py --help for details."
                    break

                if i % 1000 == 0 and print_time:
                    time_end = datetime.datetime.now()
                    time = time_end - time_init_2
                    print str(i) + ' ' + read_id + "  time: " + str(time)
                    time_init_2 = time_end
                #"""
                # print read_id
            i += 1
    else:
        sys.exit(
            "\n\nErro: Parameter -i required for script execution. \n\nUse: python kaiju_mongo.py --help for details.\n"
        )

    print "\n\nThe data was successfully stored."

if print_time:
    time_end = datetime.datetime.now()
    time = time_end - time_init
    print "total time: " + str(time)