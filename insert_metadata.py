# Author: Leandro Correa
# Date: 29.03.2017
import pandas as pd
from pymongo import MongoClient

# PATH_metadata = '/home/leandro/Data/metagenomas/Lagoas/amendoim/posdata/AM1/metadata.csv'

def mongo_insert(PATH_metadata, tool):
    up = True
    metadata_df = pd.read_csv(PATH_metadata, sep=",")

    data = {}

    for i in range(0, len(metadata_df.index)):
        key = metadata_df.iloc[i]['index']
        kwargs = metadata_df.iloc[i]['Requirement']
        if type(kwargs) is str:
            if kwargs.isalpha():
                kwargs = kwargs.upper()

        data[key] = kwargs

    client = MongoClient('localhost', 7755)
    db = client.local
    collection = db.samples
    id_sample = data.get('sample_name')
    # tool = "kaiju"
    # collection.find({'sample_name': id_sample}).count() > 0

    update = collection.update({'sample_name': id_sample},
                               {'$set': data,
                                }, upsert=False)

    if not update.get('updatedExisting'):
        objectid = collection.insert(data)
        up = False

    collection.update({'sample_name': id_sample},
                      {"$addToSet": {"tool": tool}
                       }, upsert=False)

    return up
