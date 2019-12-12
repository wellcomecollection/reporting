from io import BytesIO
import boto3


def get_s3_client(profile_name=None):
    session = boto3.session.Session(profile_name=profile_name)
    return session.client(service_name='s3')


def get_dynamo_client(profile_name=None):
    session = boto3.session.Session(profile_name=profile_name)
    return session.client(service_name='dynamodb', region_name='eu-west-1')


def get_object_from_s3(s3, bucket, key):
    response = s3.get_object(
        Bucket=bucket,
        Key=key
    )
    data = response['Body'].read()
    return BytesIO(data)


def get_object_from_dynamo(dynamodb, table, key):
    response = dynamodb.get_item(
        TableName=table,
        Key={'id': {'S': key}}
    )
    try:
        dynamo_object = response['Item']
    except KeyError:
        raise ValueError(f'{key} is not a known miro id')
    return dynamo_object
