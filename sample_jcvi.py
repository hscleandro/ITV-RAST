# Author: Leandro Correa
# Date: 29.03.2017

import pandas as pd
import sys
import os
import datetime
import re

from pymongo import MongoClient

time_init = datetime.datetime.now()
time_init_2 = datetime.datetime.now()
args = sys.argv
print_time = False

PATH_metadata = '/home/leandro/Data/metagenomas/jcvi_samples/metadata/sample_AM1_2.csv'

client = MongoClient('localhost', 7755)
db = client.local
collection = db.samples

metadata = pd.read_csv(PATH_metadata, sep=",")

#i = 16
sample = {}
change_data = False
for i in range(0, len(metadata.index)):
    key = metadata.iloc[i]['index']
    print i
    if key == 'sample_name':
        key = 'id_sample'
    kwargs = metadata.iloc[i]['Requirement']
    if key == 'total acidity':
        change_data = True
    if not change_data:
        sample[key] = kwargs
    else:
        kwargs_vet = []
        kwarg_split = str.split(kwargs, " ")
        kwargs_signal = "NA"
        kwarg_value = kwarg_split[0]
        kwarg_unity = kwarg_split[1]
        if len(kwarg_split) > 2:
            kwarg_element = kwarg_split[2]
        else:
            kwarg_element = "NA"
        if '<' in kwarg_value:
            kwarg_value = kwarg_value[1:]
            kwargs_signal = '<'

        kwargs_vet = [kwarg_value, kwarg_unity, kwarg_element, kwargs_signal]
        sample[key] = kwargs_vet

ObjectId = collection.insert(sample)