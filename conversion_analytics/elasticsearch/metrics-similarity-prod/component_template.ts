import { name as ilmName } from "./ilm";

export const name = "similarity_component_template";

export const body = {
  template: {
    settings: {
      "index.lifecycle.name": ilmName,
      analysis: {
        analyzer: {
          csv_analyzer: {
            tokenizer: "csv_tokenizer",
          },
        },
        tokenizer: {
          csv_tokenizer: {
            type: "pattern",
            pattern: ",",
          },
        },
      },
    },
    mappings: {
      dynamic: false,
      properties: {
        "@timestamp": {
          type: "date",
        },
        anonymousId: {
          type: "keyword",
        },
        session: {
          properties: {
            id: {
              type: "keyword",
            },
            timeout: {
              type: "long",
            },
          },
        },
        type: {
          type: "keyword",
        },
        source: {
          type: "keyword",
          fields: {
            wildcard: {
              type: "wildcard",
            },
          },
        },
        properties: {
          dynamic: true,
          properties: {},
        },
      },
    },
  },
};
