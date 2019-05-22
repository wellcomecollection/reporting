import os
import json
import subprocess
from tqdm import tqdm
from transform import transform
from elasticsearch import Elasticsearch
from wellcome_aws_utils.reporting_utils import get_es_credentials

es_credentials = get_es_credentials(profile_name='reporting-dev')

es = Elasticsearch(
    es_credentials["url"],
    http_auth=(es_credentials["username"], es_credentials["password"]),
)

path_to_raw_records = (
    subprocess.check_output(["git", "rev-parse", "--show-toplevel"])
    .strip()
    .decode("utf8")
    + "/calm_records.json"
)

raw_records = json.load(open(path_to_raw_records))

for raw_record in tqdm(raw_records):
    try:
        res = es.index(
            index="calm",
            id=record["RecordID"],
            doc_type="_doc",
            body=transform(raw_record)
        )
    except Exception as e:
        print(e)
