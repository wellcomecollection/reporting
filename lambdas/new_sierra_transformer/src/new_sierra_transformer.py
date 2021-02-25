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


def create_requests_for(*, record_type, record, index_name):
    index_requests = []
    delete_by_query_requests = []

    id = add_check_digit(record["id"], prefix=record_type[0])

    # For the raw record, we index everything *except* the varFields
    # and fixedFields -- these are variable size, and can cause us to
    # blow the Elasticsearch document limits.
    #
    # These fields will be indexed separately.
    print(f"Indexing data on {id}")
    indexed_data = {
        k: v for k, v in record.items() if k not in {"varFields", "fixedFields"}
    }

    index_requests.append((index_name, id, indexed_data))

    varfields = record["varFields"]
    fixed_fields = record["fixedFields"]

    # We index each varField separately.  Because varFields form an
    # ordered list, we index them under the ID/position, e.g. b12879812-3
    #
    # The _delete_by_query afterwards deletes any varFields left over
    # from a previous version of the record.
    #
    # We include some info about the parent record so you can find all
    # the varFields on a particular record.
    print(f"Indexing varFields on {id}")
    for position, vf in enumerate(varfields):
        vf["_parent"] = {
            "record_type": record_type,
            "id": id,
            "position": position,
        }

        index_requests.append(("sierra_varfields", f"{id}-{position}", vf))

    delete_by_query_requests.append(
        (
            "sierra_varfields",
            {
                "query": {
                    "bool": {
                        "filter": [
                            {"term": {"_parent.id": id}},
                            {"range": {"_parent.position": {"gte": len(varfields)}}},
                        ]
                    }
                }
            },
        )
    )

    # We index each fixedFields separately.  Because fixedFields are
    # ordered list, we index them under the ID/code, e.g. b12879812-34
    #
    # The _delete_by_query afterwards deletes any fixedFields left over
    # from a previous version of the record.
    #
    # We include some info about the parent record so you can find all
    # the fixedFields on a particular record.
    print(f"Indexing fixedFields on {id}")
    for code, ff in fixed_fields.items():
        ff["_code"] = code
        ff["_parent"] = {"record_type": record_type, "id": id}

        index_requests.append(("sierra_fixedfields", f"{id}-{code}", ff))

    delete_by_query_requests.append(
        (
            "sierra_fixedfields",
            {
                "query": {
                    "bool": {
                        "filter": [
                            {"term": {"_parent.id": id}},
                        ],
                        "must_not": [{"terms": {"_code": list(fixed_fields.keys())}}],
                    }
                }
            },
        )
    )

    return index_requests, delete_by_query_requests


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

        try:
            bib_data = json.loads(payload["transformable"]["maybeBibRecord"]["data"])
        except KeyError as err:
            print(f"No bib data for {payload['id']}: KeyError / {err}")
        else:
            bib_index_requests, bib_delete_by_query_requests = create_requests_for(
                record_type="bib", record=bib_data, index_name="sierra_bibs"
            )

            index_requests.extend(bib_index_requests)
            delete_by_query_requests.extend(bib_delete_by_query_requests)

        for item_record in payload["transformable"].get("itemRecords", {}).values():
            item_data = json.loads(item_record["data"])

            item_index_requests, item_delete_by_query_requests = create_requests_for(
                record_type="item", record=item_data, index_name="sierra_items"
            )

            index_requests.extend(item_index_requests)
            delete_by_query_requests.extend(item_delete_by_query_requests)

        for holding_record in (
            payload["transformable"].get("holdingRecords", {}).values()
        ):
            holding_data = json.loads(holding_record["data"])

            (
                holding_index_requests,
                holding_delete_by_query_requests,
            ) = create_requests_for(
                record_type="holdings",
                record=holding_data,
                index_name="sierra_holdings",
            )

            index_requests.extend(holding_index_requests)
            delete_by_query_requests.extend(holding_delete_by_query_requests)

        # Now construct a bulk request to send to Elasticsearch.
        # We do a bulk request rather than individual lines to avoid the
        # I/O penalty of each request, and hopefully fit inside the
        # Lambda 5 minute runtime.
        bulk_request_lines = []

        print(f"Indexing {len(index_requests)} documents")

        for index, id, request in index_requests:
            bulk_request_lines.append(
                json.dumps({"index": {"_index": index, "_id": id}})
            )
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
