import json
from transform import transform


def test_transform():
    vhs_data = {
        'sierraId': {
            'recordNumber': '129038'
        },
        'maybeBibRecord': {
            'id': {'recordNumber': '129038'},
            'data': json.dumps({
                'id': '129038',
                'deleted': False,
                'materialType': {
                    'code': 'a '
                },
                'varFields': [
                    {
                        'marcTag': '260',
                        'fieldTag': 'a',
                        'ind1': '1',
                        'ind2': ' ',
                        'subfields': [
                            {
                                'tag': 'a',
                                'content': 'London :'
                            },
                            {
                                'tag': 'b',
                                'content': 'Faber and Faber limited,'
                            },
                            {
                                'tag': 'c',
                                'content': '[1938]'
                            }
                        ]
                    },
                    {
                        'fieldTag': 'y',
                        'marcTag': '008',
                        'ind1': ' ',
                        'ind2': ' ',
                        'content': '181119s1658    ne            ||| | lat dnamla '
                    },
                    {
                        'fieldTag': 'y',
                        'marcTag': '007',
                        'ind1': ' ',
                        'ind2': ' ',
                        'content': 'License to kill (should not show up in expected_data)'
                    },
                    {
                        'content': "00000 km a2200361 i 4500",
                        'fieldTag': "_"
                    }
                ]
            }),
            'modifiedDate': '2018-11-12T11:55:59Z'
        }
    }
    expected_data = {
        'id': '129038',
        'material_type': 'a',
        'deleted': False,
        'varfields': {
            '260': {
                'label': 'London : Faber and Faber limited, [1938]',
                'a': 'London :',
                'b': 'Faber and Faber limited,',
                'c': '[1938]'
            },
            '008': {
                'label': '181119s1658    ne            ||| | lat dnamla '
            }
        }
    }

    assert transform(vhs_data) == expected_data
