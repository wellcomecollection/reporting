export type ParameterType = 'text' | 'keyword' | 'float' | 'csv'

const querystringParameters: Record<string, ParameterType> = {
  _queryType: 'text',
  workId: 'keyword',
  id: 'keyword',
  availabilities: 'csv',
  canvas: 'float',
  current: 'float',
  'genres.label': 'csv',
  'items.locations.locationType': 'csv',
  languages: 'csv',
  manifest: 'float',
  page: 'float',
  query: 'text',
  source: 'text',
  'subjects.label': 'csv',
  'contributors.agent.label': 'csv',
  workType: 'csv',
  resultPosition: 'float'
}

export default querystringParameters
