from hypothesis import strategies as st

from transform import (filter_out_first_page_only_sessions, split_events,
                       transform_event_group)


def test_filter_out_first_page_only_sessions(df):
    # assert that the resulting values in the page column don't go above 1
    # assert that the dataframe has its original columns but not necessarily all of its original rows (lte)
    # assert that the number of unique session ids is less than or equal to the original number
    # assert that the session ids which do include pages beyond 1 don't appear in the resulting list of ids
    assert False


def test_split_events(df):
    # assert that the result is a generator
    # assert that the next() result from the function is a tuple of a string session_id and a pandas dataframe
    # assert that the resulting next() dataframe has a single, unique anonymousId, and no page values above 1
    assert False


def test_transform_event_group(data):
    # transform specific tests
    assert False
