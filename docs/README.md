# Reporting

The typical reporting pipeline looks like:

    data source => messaging service (SQS / Kinesis) => lambda => Elasticsearch index

Source data lambdas can be seen in [the lambdas directory](../lambdas)

The `conversion` pipeline can be seen in [the conversion directory](../conversion_analytics)
