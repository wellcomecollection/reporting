# :bar_chart: Reporting

The reporting cluster lets the Data and Preservation teams keep an eye on updates to source data and metadata in the catalogue pipeline, and provides a safe environment for us to experiment with new data sources and fields.

This repo is divided into a set of python Lambdas which we use to make the source data a bit more palettable for ingestion and viewing in elasticsearch, and the terraform which keeps the whole thing running.

## Deployment
The lambdas are tested and build via [GitHub Actions](.github/main.workflow). 

Once tested, they get put into an S3 bucket as a new version. You will then need to run

```HCL
terraform apply
```

for those versions to be deployed to AWS.
