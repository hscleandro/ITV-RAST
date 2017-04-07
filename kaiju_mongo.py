# Author: Leandro Correa
# Date: 08.03.2017

import pandas as pd
import sys
import os
import datetime
import insert_metadata as metadata


from pymongo import MongoClient

# PATH_kaiju = '/home/leandro/Data/metagenomas/MG_34_Emma/kaiju/MG_34_filtered.kaiju3.names_taxon.out'

time_init = datetime.datetime.now()
time_init_2 = datetime.datetime.now()
args = sys.argv
print_time = False

if '--help' in args:
    os.system('clear')
    print 'Script: Insert a kaiju output into the Mongo metagenomic database.'
    print 'Author: Leandro Correa - @hscleandro'
    print 'Date: 09.03.2017\n'
    print 'How to use: python kaiju_mongo.py -i INPUT_KAIJU\n'
    print 'INPUT_KAIJU [required]: File containing the kaiju output.'
    print '\nInput file format: The kaiju output must contain 4 fields:'
    print '1- Tag to indicate whether the sequence was annotated or not (U or C)'
    print '2- Sequence ID'
    print '3- Taxon hierarchy'
    print '4- Taxon name\n\n'
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
        PATH_kaiju = args[args.index('-i') + 1]

        split = str.split(PATH_kaiju, '/')
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

            columns = ['status',
                       'read_id',
                       'taxon_id',
                       'taxon_name']

            kaiju_df = pd.read_csv(PATH_kaiju, sep="\t", names=columns)
            metadata_df = pd.read_csv(PATH_metadata, sep=",")

            data = {}

            for i in range(0, len(metadata_df.index)):
                key = metadata_df.iloc[i]['index']
                kwargs = metadata_df.iloc[i]['Requirement']
                data[key] = kwargs

            sample = data.get('sample_name')
            update = metadata.mongo_insert(PATH_metadata)

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

                if i % 1000 == 0 and print_time:
                    time_end = datetime.datetime.now()
                    time = time_end - time_init_2
                    print str(i) + ' ' + read_id + "\t  time: " + str(time)
                    time_init_2 = time_end
        else:
            print '\nMetadata.csv file not found.'
            sys.exit('Use -m to set the metadata adress file or write python kaiju_mongo.py --help, for details.')
    else:
        sys.exit(
            "\n\nErro: Parameter -i required for script execution. \n\nUse: python kaiju_mongo.py --help for details.\n"
        )

if print_time:
    time_end = datetime.datetime.now()
    time = time_end - time_init
    print "total time: \t" + str(time)
