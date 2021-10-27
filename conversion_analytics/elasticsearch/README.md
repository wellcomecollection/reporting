# Elasticsearch

Scripts to create the `metrics-conversion-prod` datastream. Adapted into typescript from the [instructions in the elasticsearch docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/set-up-a-data-stream.html).

To run this process, run:

- `yarn` to install necessary packages
- `yarn ts-node main.ts` to run the script. This
  - creates an index lifecycle policy (ILM)
  - creates a component template (which contains the mapping)
  - creates an index template
  - creates the datastream
