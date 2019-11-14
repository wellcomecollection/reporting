import json
from collections import MutableMapping
from datetime import datetime, timedelta

import boto3
import certifi
import pandas as pd
from elasticsearch import Elasticsearch

today = datetime.today()
yesterday = today - timedelta(days=1)


def stringify(timestamp):
    return str(timestamp).replace(' ', 'T')


def get_es_credentials(profile_name=None):
    session = boto3.session.Session(profile_name=profile_name)
    client = session.client(
        service_name='secretsmanager',
        region_name='eu-west-1'
    )
    secret_value = client.get_secret_value(
        SecretId='prod/Elasticsearch/ReportingCredentials'
    )
    return json.loads(secret_value['SecretString'])


def get_es_client():
    credentials = get_es_credentials()
    es_client = Elasticsearch(
        hosts=credentials['url'],
        use_ssl=True,
        ca_certs=certifi.where(),
        http_auth=(credentials['username'], credentials['password'])
    )
    return es_client


def flatten(nested_dict, parent_key=''):
    items = []
    for k, v in nested_dict.items():
        if isinstance(v, MutableMapping):
            items.extend(flatten(v, k).items())
        else:
            items.append((k, v))
    return dict(items)


def fetch_events(es_client, index, datetime_gte=yesterday, datetime_lt=today):
    response = es_client.search(
        index=index,
        doc_type='search',
        body={'query': {'range': {'timestamp': {
            'gte': stringify(datetime_gte),
            'lt': stringify(datetime_lt)
        }}}},
        size=100_000
    )
    data = pd.DataFrame.from_dict([
        flatten(item['_source']) for item in response['hits']['hits']
    ])
    return data
