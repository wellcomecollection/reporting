def split_events(df):
    for (anonymousId, query), query_data in df.groupby(['anonymousId', 'query']):
        yield anonymousId, query, query_data


def filter_most_recent(query_data):
    query_data['timestamp'] = pd.to_datetime(query_data['timestamp'])
    filtered = query_data.loc[[
        np.argmin(group['timestamp'])
        for _, group in query_data.groupby('position')
    ]]
    return filtered


def calculate_precision(data):
    ratings = data['rating'].values
    strict = (ratings >= 4).sum() / len(ratings)
    loose = (ratings >= 3).sum() / len(ratings)
    permissive = (ratings >= 2).sum() / len(ratings)
    return strict, loose, permissive


def transform_event_group(anonymousId, query, query_data):
    query_data = filter_most_recent(query_data)
    strict, loose, permissive = calculate_precision(query_data)
    return {
        'timestamp': query_data['timestamp'].min()
        'anonymousId': anonymousId,
        'query': query,
        'strict_precision': strict,
        'loose_precision': loose,
        'permissive_precision': permissive
    }
