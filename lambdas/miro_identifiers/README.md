# Miro identifiers :label:

Lambda to unify miro images' identifiers. Takes useful data from various miro-related dynamo tables and s3 buckets and dumps it into the `miro_identifiers` elasticsearch index. This data is used by the `palette-similarity` and `feature-similarity` APIs.
