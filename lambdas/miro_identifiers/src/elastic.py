import os

from elasticsearch import Elasticsearch
from wellcome_aws_utils.reporting_utils import get_es_credentials


def get_es_client():
    es_credentials = get_es_credentials(profile_name='reporting-dev')
    es_client = Elasticsearch(
        es_credentials['url'],
        http_auth=(es_credentials['username'], es_credentials['password']),
    )
    return es_client
