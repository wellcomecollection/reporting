# Indices

We have several historical indices related to search and conversion in the reporting cluster. As our data collection requirements have matured, so have the corresponding indices.

In chronological order, we've used:

- `tracking_search` (deprecated)  
  rapidly developed as part of a spike to determine whether we could track more useful data on how people used search than google analytics.
- `search_relevance_implicit` (deprecated)  
  a slightly more refined version of the above. Broadly, we tracked 3 events:
  - `Search landing` - someone landed on the search page
  - `Search` - a search was made
  - `Search result selected` - a result was selected
- `search_relevance_explicit` (deprecated)  
  Collected data from a feature which allowed people to explicitly rate the relevance of their search results on a scale of 1-4, in order to feed a calculation of [NDCG](https://en.m.wikipedia.org/wiki/Discounted_cumulative_gain) for new candidate algorithms. The feature was so infrequently used that we quickly abandoned this approach.
- `conversion` (deprecated)  
  Expanded the range of events tracked to include item and image views in order to get a better sense of the conversion journey. Major shift in the structure of the collected data.
- `metrics-conversion-prod`
  Our most recent version of the data pipeline places the same events from the `conversion` pipeline into a more conservative, restricted version of the same mapping. It is set up as a [data-stream](https://www.elastic.co/guide/en/elasticsearch/reference/master/data-streams.html) instead of a regular index.
