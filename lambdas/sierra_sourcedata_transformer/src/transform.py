import json
from copy import deepcopy
from datetime import datetime, timedelta
from dateutil.parser import parse


def transform(input_data):
    # only look at the bib data for now
    try:
        json_string = input_data["maybeBibRecord"]["data"]
        bib_record = json.loads(json_string)
    except (KeyError, TypeError):
        bib_record = {}

    transformed = deepcopy(bib_record)

    return transformed
