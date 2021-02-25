import json
import os

import boto3
import httpx


def get_es_credentials():
    """
    Returns Elasticsearch credentials for the reporting cluster.
    """
    client = boto3.client("secretsmanager")
    get_secret_value_response = client.get_secret_value(
        SecretId="prod/Elasticsearch/ReportingCredentials"
    )
    secret = get_secret_value_response["SecretString"]
    return json.loads(secret)


def get_aws_client(resource, *, role_arn):
    sts_client = boto3.client("sts")
    assumed_role_object = sts_client.assume_role(
        RoleArn=role_arn, RoleSessionName="AssumeRoleSession1"
    )
    credentials = assumed_role_object["Credentials"]
    return boto3.client(
        resource,
        aws_access_key_id=credentials["AccessKeyId"],
        aws_secret_access_key=credentials["SecretAccessKey"],
        aws_session_token=credentials["SessionToken"],
    )


def get_payloads(event, *, s3_read_role):
    """
    Given the Lambda event, generate the payloads that describe the
    different Sierra transformables we want to emit.
    """
    s3_client = get_aws_client("s3", role_arn=s3_read_role)

    for r in event["Records"]:
        message = json.loads(r["Sns"]["Message"])

        transformable = json.load(
            s3_client.get_object(
                Bucket=message["location"]["bucket"], Key=message["location"]["key"]
            )["Body"]
        )

        yield {
            "id": message["id"],
            "version": message["version"],
            "transformable": transformable,
        }


def add_check_digit(id, *, prefix):
    total = sum(i * int(digit) for i, digit in enumerate(reversed(id), start=2))

    if total % 11 == 10:
        return prefix + id + "x"
    else:
        return prefix + id + str(total % 11)


def main(event, _):
    credentials = get_es_credentials()
    es_client = httpx.Client(
        base_url=credentials["url"],
        auth=(credentials["username"], credentials["password"]),
    )

    s3_read_role = os.environ["assumable_read_role"]

    index_requests = []
    delete_by_query_requests = []

    for payload in get_payloads(event, s3_read_role=s3_read_role):

        # Index the bib record, with the varFields and fixedFields
        # going to a separate index.
        try:
            bib_data = json.loads(payload["transformable"]["maybeBibRecord"]["data"])
        except KeyError as err:
            print(f"No bib data for {payload['id']}: KeyError / {err}")
        else:
            indexed_bib_data = {
                k: v
                for k, v in bib_data.items()
                if k not in {"varFields", "fixedFields"}
            }

            bib_id = add_check_digit(bib_data["id"], prefix="b")

            print(f"Indexing data on {bib_id}")
            index_requests.append(
                ({"index": {"_index": "sierra_bibs", "_id": bib_id}}, indexed_bib_data)
            )

            print(f"Indexing varFields on {bib_id}")
            for position, vf in enumerate(bib_data["varFields"]):
                vf["_parent"] = {
                    "record_type": "bib",
                    "id": bib_id,
                    "position": position,
                }

                index_requests.append(
                    (
                        {
                            "index": {
                                "_index": "sierra_varfields",
                                "_id": f"{bib_id}-{position}",
                            }
                        },
                        vf,
                    )
                )

            delete_by_query_requests.append(
                (
                    "sierra_varfields",
                    {
                        "query": {
                            "bool": {
                                "filter": [
                                    {"term": {"_parent.id": bib_id}},
                                    {
                                        "range": {
                                            "_parent.position": {
                                                "gte": len(bib_data["varFields"])
                                            }
                                        }
                                    },
                                ]
                            }
                        }
                    },
                )
            )

            print(f"Indexing fixedFields on {bib_id}")
            for code, fixed_field in bib_data["fixedFields"].items():
                fixed_field["_code"] = code
                fixed_field["_parent"] = {"record_type": "bib", "id": bib_id}

                index_requests.append(
                    (
                        {
                            "index": {
                                "_index": "sierra_fixedfields",
                                "_id": f"{bib_id}-{code}",
                            }
                        },
                        fixed_field,
                    )
                )

            delete_by_query_requests.append(
                (
                    "sierra_fixedfields",
                    {
                        "query": {
                            "bool": {
                                "filter": [
                                    {"term": {"_parent.id": bib_id}},
                                ],
                                "must_not": [
                                    {
                                        "terms": {
                                            "_code": list(
                                                bib_data["fixedFields"].keys()
                                            )
                                        }
                                    }
                                ],
                            }
                        }
                    },
                )
            )

        # Now construct a bulk request to send to Elasticsearch.
        # We do a bulk request rather than individual lines to avoid the
        # I/O penalty of each request, and hopefully fit inside the
        # Lambda 5 minute runtime.
        bulk_request_lines = []

        print(f"Indexing {len(index_requests)} documents")

        for index, request in index_requests:
            bulk_request_lines.append(json.dumps(index))
            bulk_request_lines.append(json.dumps(request))

        # TODO: Look for documents that didn't get indexed correctly
        resp = es_client.post(
            "/_bulk",
            headers={"Content-Type": "application/x-ndjson"},
            data="\n".join(bulk_request_lines) + "\n",
        )
        print(resp.text)
        resp.raise_for_status()

        for index, query in delete_by_query_requests:
            resp = es_client.post(f"/{index}/_delete_by_query", json=query)
            resp.raise_for_status()
