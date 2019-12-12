from .aws import (get_dynamo_client, get_object_from_dynamo,
                  get_object_from_s3, get_s3_client)
from .elastic import get_es_client
from .identifiers import (get_catalogue_id_miro, get_catalogue_id_sierra,
                          get_feature_index, get_palette_index)

from wellcome_aws_utils.reporting_utils import extract_sns_messages_from_event


es_client = get_es_client()
platform_dynamo = get_dynamo_client('platform-dev')
platform_s3 = get_s3_client('platform-dev')


def get_identifiers(miro_id):
    # fetch metadata and identifiers
    is_cleared_for_catalogue_api = get_object_from_dynamo(
        platform_dynamo, 'vhs-sourcedata-miro', miro_id
    )['isClearedForCatalogueAPI']['BOOL']

    catalogue_id_sierra = get_catalogue_id_sierra(miro_id)
    catalogue_id_miro = get_catalogue_id_miro(
        platform_dynamo, platform_s3, miro_id
    )

    palette_index = get_palette_index(miro_id)
    feature_index = get_feature_index(miro_id)

    # combine data to build record for es
    identifiers = {
        'miro_id': miro_id,
        'is_cleared_for_catalogue_api': is_cleared_for_catalogue_api,
        'catalogue_id_sierra': catalogue_id_sierra,
        'catalogue_id_miro': catalogue_id_miro,
        'palette_index': palette_index,
        'feature_index': feature_index
    }
    return identifiers


def main(event, _):
    for message in extract_sns_messages_from_event(event):
        miro_id = message['id']
        identifiers = get_identifiers(miro_id)
        es_client.index(
            index='miro_identifiers',
            doc_type='_doc',
            body=identifiers
        )
