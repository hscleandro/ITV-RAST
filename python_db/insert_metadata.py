# Author: Leandro Correa
# Date: 29.03.2017
import pandas as pd
from pymongo import MongoClient
import os
import sys
from progressbar.progressbar import *
# PATH_metadata = '/home/leandro/Data/metagenomas/Lagoas/amendoim/posdata/AM1/metadata.csv'
args = sys.argv


if '--help' in args:
    os.system('clear')
    print 'Script: Insert metadata samples into the Mongo metagenomic database.'
    print 'Author: Leandro Correa - @hscleandro'
    print 'Date: 06.06.2017\n'
    print 'How to use: python insert_metadata.py -i METADATA.CSV -s SAMPLE -p PROJECT -time\n'
    print 'SAMPLE [required]: Sample name.'
    print 'PROJECT [required]: Project name.'
    print 'METADATA.CSV [required]: File containing the metadata of the sample. ' \
          ' The metadata.csv file must contain two columns titled: Index and Requirement, as in the example:\n'

    print '+-----------------------------------+\n'\
          '|     Index        |  Requirement   |\n'\
          '+------------------+----------------+\n'\
          '|   type_of_sample |    Water       |\n'\
          '+------------------+----------------+\n'\
          '|   type_sequence  |    contig      |\n'\
          '+------------------+----------------+\n'\
          '|   assembler_tool |    Spades      |\n'\
          '+------------------+----------------+\n'

    print 'time: Graph indicating the total and expected completion time of the execution.\n\n'
    sys.exit('')

else:
    if '-i' in args:
        PATH_metadata = args[args.index('-i') + 1]

        split = str.split(PATH_metadata, '/')
        PATH = ''
        for s in range(1, len(split[:-1])):
            PATH = PATH + '/' + split[s]
        PATH += '/'
    else:
        sys.exit(
            "\n\nErro: Parameter -i required for script execution. \n\nUse: python insert_metadata.py --help for details.\n"
        )
    if '-s' in args:
        sample = args[args.index('-s') + 1]
    else:
        sys.exit(
            "\n\nErro: Parameter -s required for script execution. \n\nUse: python insert_metadata.py --help for details.\n"
        )
    if '-p' in args:
        project = args[args.index('-p') + 1]
    else:
        sys.exit(
            "\n\nErro: Parameter -p required for script execution. \n\nUse: python insert_metadata.py --help for details.\n"
        )
    if '-time' in args:
        print_time = True
    else:
        print_time = False

    client = MongoClient('localhost', 7755)
    db = client.local
    collection_sample = db.samples
    metadata_df = pd.read_csv(PATH_metadata, sep=",")

    if print_time:
        print '\nLoading. . .\n'
        widgets = ['Update: ', Percentage(), ' ', Bar(marker=RotatingMarker()), ' ', ETA(), ' ', FileTransferSpeed()]

        print str(len(metadata_df.index)) + ' instances to be inserted in the mongo database.\n\n'
        pbar = ProgressBar(widgets=widgets, maxval=len(metadata_df.index) * 1000).start()

    data = {}

    for i in range(0, len(metadata_df.index)):
        key = metadata_df.iloc[i]['Index']
        kwargs = metadata_df.iloc[i]['Requirement']
        if type(kwargs) is str:
            if kwargs.isalpha():
                kwargs = kwargs.upper()

        data[key] = kwargs

        if print_time:
            pbar.update(1000 * i + 1)
    if print_time:
        pbar.finish()

    update = collection_sample.update({"$and":
                                    [{
                                       "sample_name": sample,
                                       "project": project,
                                    }]},
                               {'$set': data,
                               }, upsert=False)

    if not update.get('updatedExisting'):
        objectid = collection_sample.insert(data)

    collection_sample.update({"$and":
                            [{
                               "sample_name": sample,
                               "project": project,
                            }]},
                      {'$set': {"metadata_tool": "OK"}
                      }, upsert=False)

print "\n\nThe data was successfully stored."