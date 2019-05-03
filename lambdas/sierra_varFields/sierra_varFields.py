import sys
import os

# This is used for local testing and shouldn't affect lamdas
# As a non-existing path doesn't matter
sys.path.insert(0, os.path.abspath('../../lambda_layers/python'))

from elasticsearch import Elasticsearch

def main(event, context):
    print(event, Elasticsearch)
