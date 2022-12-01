# Elasticsearch

Scripts to create and update the `metrics-conversion-prod` or `metrics-similarity-prod` datastreams. 

Adapted into typescript from the [instructions in the elasticsearch docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/set-up-a-data-stream.html).

## Instructions

First run `yarn` to install necessary packages.

### Create a datastream

Run `yarn createDataStream`. This:

- creates an index lifecycle policy (ILM)
- creates a component template (which contains the mapping)
- creates an index template
- creates the datastream

### Update a datastream's mapping

Run

- `yarn updateMapping` to update the mapping of the datastream
- `yarn updateByQueryAll` to update all existing documents in the datastream to match the new mapping
