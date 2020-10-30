import pandas as pd
import collections
import json
import os

import boto3
from elasticsearch import Elasticsearch
from weco_datascience.credentials import get_secrets
from weco_datascience.logging import get_logger

log = get_logger(__name__)

credentials = get_secrets("reporting/search_elastic_credentials")
es_client = Elasticsearch(
    hosts=[credentials["endpoint"]],
    http_auth=(credentials["username"], credentials["password"])
)


def flatten(d, parent_key=''):
    items = []
    for k, v in d.items():
        new_key = parent_key + "_" + k if parent_key else k
        if isinstance(v, collections.MutableMapping):
            items.extend(flatten(v, new_key).items())
        else:
            items.append((new_key, v))
    return dict(items)


def get_data(start, end):
    response = es_client.search(
        index="search_relevance_implicit",
        body={
            "query": {
                "range": {
                    "timestamp": {
                        "gte": start,
                        "lt": end
                    }
                }
            },
            "size": 100_000
        }
    )
    df = pd.DataFrame([
        flatten(hit["_source"]) for hit in response["hits"]["hits"]
    ])
    return df
