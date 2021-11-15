import json

import boto3

assumed_role_object = boto3.client("sts").assume_role(
    RoleArn="arn:aws:iam::760097843905:role/platform-developer",
    RoleSessionName="AssumeRoleSession1",
)

secretsmanager = boto3.Session(
    aws_access_key_id=assumed_role_object["Credentials"]["AccessKeyId"],
    aws_secret_access_key=assumed_role_object["Credentials"]["SecretAccessKey"],
    aws_session_token=assumed_role_object["Credentials"]["SessionToken"],
).client("secretsmanager")

secrets = json.loads(
    secretsmanager.get_secret_value(
        SecretId="elasticsearch/reporting/saved_objects_getter"
    )["SecretString"]
)

kibana_url = (
    f"https://{secrets['username']}:{secrets['password']}"
    f"@{secrets['host']}:{secrets['port']}"
)
