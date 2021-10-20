import { name as ilmName } from "./ilm"
import querystringParameters from "./querystringParameters"

export const name = 'conversion_component_template'

export const body = {
  "template": {
    "settings": {
      "index.lifecycle.name": ilmName,
      "analysis": {
        "analyzer": {
          "csv_analyzer": {
            "tokenizer": "csv_tokenizer"
          }
        },
        "tokenizer": {
          "csv_tokenizer": {
            "type": "pattern",
            "pattern": ","
          }
        }
      }
    },
    "mappings": {
      "dynamic": false,
      "dynamic_templates": [
        {
          "properties_params": {
            "path_match": "properties.*",
            "mapping": {
              "type": "text",
              "fields": {
                "keyword": {
                  "type": "keyword"
                },
                "csv": {
                  "type": "text",
                  "analyzer": "csv_analyzer"
                },
                "number": {
                  "type": "long",
                  "ignore_malformed": true
                },
                "wildcard": {
                  "type": "wildcard"
                }
              }
            }
          }
        }
      ],
      "properties": {
        "@timestamp": {
          "type": "date"
        },
        "anonymousId": {
          "type": "keyword"
        },
        "session": {
          "properties": {
            "id": {
              "type": "keyword"
            },
            "timeout": {
              "type": "long"
            }
          }
        },
        "type": {
          "type": "keyword"
        },
        "source": {
          "type": "keyword",
          "fields": {
            "wildcard": {
              "type": "wildcard"
            }
          }
        },
        "page": {
          "properties": {
            "name": {
              "type": "keyword"
            },
            "path": {
              "type": "keyword"
            },
            "pathname": {
              "type": "keyword"
            },
            "query": {
              "dynamic": false,
              "properties": Object.entries(querystringParameters).reduce((acc, [key, type]) => {
                const typeObj =
                  type === 'csv' ? { type: 'text', "analyzer": "csv_analyzer" } :
                  type === 'float' ? { type: 'float', ignore_malformed: true } :
                  { type }
                return {
                  ...acc,
                  [key]: typeObj
                }
              }, {})
            }
          }
        },
        "properties": {
          "dynamic": true,
          "properties": {}
        }
      }
    }
  },
}
