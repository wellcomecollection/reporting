import { name as componentTemplateName } from './component_template'

// PUT _index_template/conversion_index_template
export const name = 'conversion_index_template'
export const indexPatternName = 'metrics-conversion-prod'

export const body = {
  index_patterns: [`${indexPatternName}*`],
  data_stream: { },
  composed_of: [componentTemplateName],
  priority: 500
}
