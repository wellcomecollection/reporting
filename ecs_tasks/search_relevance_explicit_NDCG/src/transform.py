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


def calculate_dcg(data):
    return np.sum([
        rating / math.log(position + 2, 2)
        for position, rating in data
    ])


def calculate_ndcg(data):
    dcg = calculate_dcg(data[['position', 'rating']].values)
    idcg = calculate_dcg([(i, v) for i, v in enumerate(
        data['rating'].sort_values(ascending=False)
    )])
    ndcg = dcg / idcg
    return dcg, ndcg


def transform_event_group(anonymousId, query, query_data):
    query_data = filter_most_recent(query_data)
    dcg, ndcg = calculate_ndcg(query_data)
    return {
        'timestamp': query_data['timestamp'].min()
        'anonymousId': anonymousId,
        'query': query,
        'session_length': len(query_data),
        'mean_dcg': dcg / len(query_data),
        'ndcg': ndcg
    }
