import json
import datetime
from copy import deepcopy
from transform import transform


def build_bib_record():
    bib_record = {
        "string_field": "some string",
        "boolean_field": True,
        "single_dict_single_subfield": {"a": "b"},
        "single_dict_multiple_subfields": {"a": "b", "x": "y"},
        "multiple_dicts_single_subfield": [{"a": "b"}, {"a": "c"}],
        "multiple_dicts_multiple_subfields": [
            {"a": "b", "x": "y"},
            {"a": "c", "x": "z"},
        ],
        "orders_date": ["2003-02-01T00:00:00"],
        "publishYear": 1970,
        "empty_string": "",
    }
    return bib_record


def build_sierra_transformable():
    bib_record = build_bib_record()
    sierra_transformable = {
        "sierraId": {"recordNumber": "3075974"},
        "maybeBibRecord": {
            "id": {"recordNumber": "3075974"},
            "data": json.dumps(bib_record),
            "modifiedDate": "2018-11-12T11:55:59Z",
        },
        "itemRecords": {},
    }
    return sierra_transformable


def test_transform():
    raw_data = build_sierra_transformable()
    transformed = transform(raw_data)

    assert type(transformed) == dict
