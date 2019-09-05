# :bar_chart: Reporting

The reporting project is setup to help us understand, analyse, and report on the different parts of the
catalogue.

This includes (non-exhaustive):
- Data sources feeding the cataogue API
- How the API is used
- Feedback on the API

On average the reporting pipeline looks like:

    data source => messaging service (SQS / Kinesis) => lambda => Elasticsearch index

The different pipelines can be found in [`./lambdas`](./lambdas), where each pipeline
_should_ have a README.


## Deployment
The lambdas are tested and pushed to S3 as a new versions via [GitHub Actions](.github/workflows/).

To deploy these, terraform reads the version from S3 object and deploys it.
You can do this from the [`terraform`](terraform) folder by running:

```HCL
terraform apply
```
