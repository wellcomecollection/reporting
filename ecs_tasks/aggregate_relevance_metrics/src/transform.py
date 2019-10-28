def filter_out_first_page_only_sessions(df):
    max_page_per_session = df.groupby('anonymousId')['page'].max()
    session_ids_beyond_first_page = set(
        max_page_per_session[max_page_per_session > 1].index.values
    )
    return df[~df['anonymousId'].isin(session_ids_beyond_first_page)]


def split_events(df):
    df = filter_out_first_page_only_sessions(df)
    for group_id, event_group in df.groupby('anonymousId'):
        yield group_id, event_group


def transform_event_group(data):
    clicks = data[data['event'] == 'Search Result Selected']
    if len(clicks) > 0:
        transformed_data = {
            'mean position': clicks['position'].mean(),
            'size': len(clicks),
            'actual values': clicks['position'].tolist()
        }
    else:
        transformed_data = None
    return transformed_data
