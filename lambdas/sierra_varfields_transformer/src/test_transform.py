from transform import transform

def test_transform():
    vhs_data = {
        'id': '129038',
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
            }
        ]
    }
    expected_data = {
        'id': '129038',
        'material_type': 'a',
        'varfields': {
            '260': {
                'label': 'London : Faber and Faber limited, [1938]',
                'a': 'London :',
                'b': 'Faber and Faber limited,',
                'c': '[1938]'
            }
        }
    }
    assert transform(vhs_data) == expected_data

