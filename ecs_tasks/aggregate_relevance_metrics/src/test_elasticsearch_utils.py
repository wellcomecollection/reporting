import pandas as pd
from hypothesis import given
from hypothesis import strategies as st

from .elasticsearch_utils import flatten, stringify


@given(st.datetimes())
def test_stringify(timestamp):
    result = stringify(timestamp)
    assert type(result) == str
    assert result[10] == 'T'


def test_flatten():
    nested_data = {
        'event': 'Search',
        'anonymousId': '281060bd-1369-4311-8a91-070f864abc0f',
        'timestamp': '2019-10-28T16:51:18.605Z',
        'network': None,
        'toggles': {'toggle_newsletterPromoUpdate': 'true',
                    'toggle_searchCandidateQueryBoost': 'true',
                    'toggle_searchCandidateQueryMsm': 'false',
                    'toggle_searchCandidateQueryMsmBoost': 'false',
                    'toggle_searchWithNotes': 'true'},
        'data': {'_queryType': None,
                 'page': 1,
                 'production.dates.from': None,
                 'production.dates.to': None,
                 'query': 'V0029387',
                 'workType': ['k', 'q']}
    }
    flat_data = {
        'event': 'Search',
        'anonymousId': '281060bd-1369-4311-8a91-070f864abc0f',
        'timestamp': '2019-10-28T16:51:18.605Z',
        'network': None,
        'toggle_newsletterPromoUpdate': 'true',
        'toggle_searchCandidateQueryBoost': 'true',
        'toggle_searchCandidateQueryMsm': 'false',
        'toggle_searchCandidateQueryMsmBoost': 'false',
        'toggle_searchWithNotes': 'true',
        '_queryType': None,
        'page': 1,
        'production.dates.from': None,
        'production.dates.to': None,
        'query': 'V0029387',
        'workType': ['k', 'q']
    }
    assert flatten(nested_data) == flat_data
