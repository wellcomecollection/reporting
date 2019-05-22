# :bar_chart: Reporting

The reporting cluster lets us keep an eye on updates to source data and metadata in the pipeline, and serves as a safe environment to experiment with new data sources and fields.

This repo is divided into a set of python Lambdas which we use to make the source data a bit more palettable for ingestion and viewing in elasticsearch, and the terraform which keeps the whole thing running.