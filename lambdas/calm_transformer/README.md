# Calm transformer

This basic transformer cleans up a static copy of the Calm data before sending it off to an elasticsearch index.

The Calm transformer is unlike the others in this repo in that it isn't really supposed to run in a Lambda at this point; Calm hasn't been properly wired up as a data source in the pipeline and until that's the case, there won't be any live updates to read. Until then, the elasticsearch index can be populated on an ad-hoc basis using the `calm_transformer.py` script.

The raw Calm data can be obtained by running the `download_oai_harvest.py` script (which can be found [here](https://github.com/wellcometrust/platform/blob/master/monitoring/scripts/download_oai_harvest.py)) from the root of this repo. This will create a file called `calm_records.json` which is subsequenty read by `calm_transformer.py`. Each record is parsed, transformed and pushed to elasticsearch in a single session.