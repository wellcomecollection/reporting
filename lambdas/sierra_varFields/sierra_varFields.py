import sys
import os
import json
import base64
import certifi

import boto3
import botocore

# This is used for local testing and will not get used by lambdas.
# It doesn't matter as adding an empty path never hurt anyone.
sys.path.insert(0, os.path.abspath('../../lambda_layers/python'))
from elasticsearch import Elasticsearch
from elasticsearch import helpers

s3_client = boto3.client('s3')

# TODO:
# * Error handling
# * Logging
# * Move bits into layers i.e. Elasticsearch
def get_es_credentials():
    secret_name = "prod/Elasticsearch/ReportingCredentials"
    region_name = "eu-west-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    get_secret_value_response = client.get_secret_value(
        SecretId=secret_name
    )
    secret = get_secret_value_response['SecretString']
    return json.loads(secret)

def flatten_varField(varField):
    full_content_delimeter = ' '
    label = full_content_delimeter.join([subfield['content'] for subfield in varField['subfields']])
    flattened_subfields = {subfield['tag']: subfield['content'] for subfield in varField['subfields']}
    return {
        'label': label,
        **flattened_subfields
    }

index = 'reporting_sierra_varfields'
def main(event, context):
    message_json_string = event['Records'][0]['Sns']['Message']
    message = json.loads(message_json_string)
    location = message['location']
    response = s3_client.get_object(Bucket=location['namespace'], Key=location['key'])
    body = response['Body'].read().decode('utf-8')
    s3Json = json.loads(body)
    maybe_bib_record = s3Json['maybeBibRecord']
    if (maybe_bib_record):
        data = json.loads(maybe_bib_record['data'])
        material_type = data['materialType']['code'].strip()

        varFields = data['varFields']
        id = data['id']

        if len(varFields) > 1:
            es_credentials = get_es_credentials()
            es = Elasticsearch(
                es_credentials['url'],
                http_auth=(es_credentials['username'], es_credentials['password']),
                use_ssl=True,
                ca_certs=certifi.where(),
            )
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
            We then do updates, which will eventually lead us to
            """
            flattened_varFields = {varField['marcTag']: flatten_varField(varField) for varField in varFields if 'subfields' in varField}
            res = es.update(
                index=index,
                id=id,
                body={
                    'doc': {
                        'material_type': material_type,
                        'varfields': flattened_varFields
                    },
                    'doc_as_upsert': True
                },
                doc_type='doc'
            )
            print('Tried to index with result:')
            print(res)
        else:
            print('No varFields to index for record {}'.format(id))

