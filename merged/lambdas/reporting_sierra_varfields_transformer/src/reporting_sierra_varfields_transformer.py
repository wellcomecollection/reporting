from wellcome_aws_utils.reporting_utils import (get_es_credentials,
                                                process_messages)

from transform import transform

credentials = get_es_credentials()


def main(event, _):
    process_messages(
        event=event,
        transform=transform,
        index='sierra_varfields',
        credentials=credentials
    )
