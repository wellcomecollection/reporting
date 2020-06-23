from wellcome_aws_utils.reporting_utils import (get_es_credentials,
                                                process_messages)

credentials = get_es_credentials()

def main(event, _):
    process_messages(
        event=event,
        transform=transform,
        index='calm',
        credentials=credentials
    )

def transform(record):
    return record['data']
