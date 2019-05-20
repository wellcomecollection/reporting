from wellcome_aws_utils.reporting_utils import process_messages

from transform import transform


def main(event, _):
    process_messages(event, transform, 'sierra_varfields')
