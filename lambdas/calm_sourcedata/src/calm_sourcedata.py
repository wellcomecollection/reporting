from os import environ
import boto3

from wellcome_aws_utils.reporting_utils import (get_es_credentials,
                                                process_messages)

credentials = get_es_credentials()

assumable_read_role = environ["assumable_read_role"]

def main(event, _):
    (dynamodb, s3) = get_dynamodb_and_s3(assumable_read_role)
    process_messages(
        event=event,
        transform=transform,
        index='calm_catalog',
        table_name='vhs-calm-adapter',
        dynamodb=dynamodb,
        s3_client=s3,
        credentials=credentials
    )

def transform(record):
    return record['data']

def get_dynamodb_and_s3(role_arn):
    sts = boto3.client("sts")
    role = sts.assume_role(RoleArn=role_arn, RoleSessionName="AssumeRoleSession1")
    credentials = role['Credentials']
    session = boto3.session.Session(
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken']
    )
    dynamodb = session.resource("dynamodb")
    s3 = session.client("s3")
    return (dynamodb, s3)
