import collections
import json

import boto3
import certifi
import pandas as pd
from elasticsearch import Elasticsearch


def stringify(timestamp): return str(timestamp).replace(' ', 'T')


today = pd.Timestamp.today(tz='Europe/London')
yesterday = today - pd.Timedelta(days=1)


def get_es_credentials(profile_name=None):
    session = boto3.session.Session(profile_name=profile_name)
    client = session.client(
        service_name='secretsmanager',
        region_name='eu-west-1'
    )
    get_secret_value_response = client.get_secret_value(
        SecretId='prod/Elasticsearch/ReportingCredentials'
    )
    secret = get_secret_value_response['SecretString']
    return json.loads(secret)


def get_es_client():
    credentials = get_es_credentials()
    es_client = Elasticsearch(
        hosts=credentials['url'],
        use_ssl=True,
        ca_certs=certifi.where(),
        http_auth=(credentials['username'], credentials['password'])
    )
    return es_client


def flatten(d, parent_key='', sep='.'):
    items = []
    for k, v in d.items():
        if isinstance(v, collections.MutableMapping):
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
        size=100_000,
        _source_include=['anonymousId', 'event', 'data', 'timestamp']
    )
    data = pd.DataFrame.from_dict([
        flatten(item['_source']) for item in response['hits']['hits']
    ])
    return data
