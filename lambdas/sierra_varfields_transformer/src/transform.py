import json

import certifi
from elasticsearch import Elasticsearch
from wellcome_aws_utils.reporting_utils import get_es_credentials


def flatten_varfield(varfield):
    label = ' '.join([
        subfield['content'] for subfield in varfield['subfields']
    ])
    flattened_subfields = {
        subfield['tag']: subfield['content']
        for subfield in varfield['subfields']
    }
    flattened_varfield = {'label': label, **flattened_subfields}
    return flattened_varfield


def transform(input_data):
    """
    We're looking for a format of
    {
        "id": "129038",
        "varfields": {
            "260": {
                "label": "London : Faber and Faber limited, [1938]",
                "a": "London : ",
                "b": "Faber and Faber limited,",
                "c": "[1938]"
            }
        }
    }
    """
    data = json.loads(input_data['maybeBibRecord']['data'])
    flattened_varfields = {
        varfield['marcTag']: flatten_varfield(varfield)
        for varfield in data['varfields'] 
        if 'subfields' in varfield
    }
    return flattened_varfields
