import json

import certifi
from wellcome_aws_utils.reporting_utils import get_es_credentials


def flatten_varfield(varfield):
    content_label = varfield.get('content')
    subfields = varfield.get('subfields') or []
    subfields_label = ' '.join([
        subfield['content'] for subfield in subfields
    ])
    label = content_label or subfields_label
    flattened_subfields = {
        subfield['tag']: subfield['content']
        for subfield in subfields
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

    varfields_whitelist = [
        "260", "264", "008", "240", "130", "250", "245", "246"
    ]
    data_str = input_data['maybeBibRecord']['data']
    data = json.loads(data_str)

    if data.get('deleted' == True):
        return None

    flattened_varfields = {
        varfield['marcTag']: flatten_varfield(varfield)
        for varfield in data['varFields']
        if varfield.get("marcTag") and varfield["marcTag"] in varfields_whitelist
    }
    material_type = data['materialType']['code'].strip(
    ) if data.get('materialType') else None
    return {
        'id': data['id'],
        'material_type': material_type,
        'varfields': flattened_varfields
    }
