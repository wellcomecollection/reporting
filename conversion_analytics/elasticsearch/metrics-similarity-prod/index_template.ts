import { name as componentTemplateName } from "./component_template";

export const name = "similarity_index_template";
export const indexPatternName = "metrics-similarity-prod";

export const body = {
  index_patterns: [`${indexPatternName}*`],
  data_stream: {},
  composed_of: [componentTemplateName],
  priority: 500,
};
