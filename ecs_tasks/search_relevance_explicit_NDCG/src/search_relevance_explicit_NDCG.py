from elasticsearch_utils import fetch_events, get_es_client
from transform import split_events, transform_event_group

# fetch events log from elasticsearch
es_client = get_es_client()
all_events = fetch_events(
    es_client=es_client,
    index='tracking_search'
)

# process events and send them to the rolled elasticsearch index
for group_id, event_group in split_events(all_events):
    transformed_data = transform_event_group(event_group)
    if transformed_data is not None:
        es_client.index(
            index='search_relevance_explicit_NDCG',
            doc_type="_doc",
            id=group_id,
            body=transformed_data
        )
