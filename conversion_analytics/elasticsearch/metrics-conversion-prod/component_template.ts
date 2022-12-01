import querystringParameters, { ParameterType } from "./querystringParameters";

import { name as ilmName } from "./ilm";

type ElasticType = { type: string; [key: string]: unknown };
function parameterToElasticType(
  key: string,
  parameterType: ParameterType
): ElasticType {
  // `query` is a special use case where we have both text and keyword.
  // To avoid overloading  querystringParameters, we support that edgecase here
  if (key === "query") {
    return {
      type: "text",
      fields: { keyword: { type: "keyword" } },
    };
  }

  switch (parameterType) {
    case "csv":
      return {
        type: "text",
        analyzer: "csv_analyzer",
        fields: { keyword: { type: "keyword" } },
      };
    case "float":
      return { type: "float", ignore_malformed: true };
    case "keyword":
      return { type: "keyword" };
    case "text":
      return { type: "text" };
  }
}

export const name = "conversion_component_template";

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
      dynamic_templates: [
        {
          properties_params: {
            path_match: "properties.*",
            mapping: {
              type: "text",
              fields: {
                keyword: {
                  type: "keyword",
                },
                csv: {
                  type: "text",
                  analyzer: "csv_analyzer",
                },
                number: {
                  type: "long",
                  ignore_malformed: true,
                },
                wildcard: {
                  type: "wildcard",
                },
              },
            },
          },
        },
      ],
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
        page: {
          properties: {
            name: {
              type: "keyword",
            },
            path: {
              type: "keyword",
            },
            pathname: {
              type: "keyword",
            },
            query: {
              dynamic: false,
              properties: Object.entries(querystringParameters).reduce(
                (acc, [key, parameterType]) => {
                  return {
                    ...acc,
                    [key.replace(/\./g, "_")]: parameterToElasticType(
                      key,
                      parameterType
                    ),
                  };
                },
                {}
              ),
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
