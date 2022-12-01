export type ParameterType = "text" | "keyword" | "float" | "csv";

const querystringParameters: Record<string, ParameterType> = {
  _queryType: "text",
  color: "keyword",
  "contributors.agent.label": "csv",
  "genres.label": "csv",
  "items.locations.locationType": "csv",
  "locations.license": "csv",
  "partOf.title": "keyword",
  "source.genres.label": "csv",
  "source.subjects.label": "csv",
  "subjects.label": "csv",
  "production.dates.to": "float",
  "production.dates.from": "float",
  availabilities: "csv",
  canvas: "float",
  current: "float",
  id: "keyword",
  languages: "csv",
  manifest: "float",
  page: "float",
  query: "text",
  resultPosition: "float",
  source: "text",
  workId: "keyword",
  workType: "csv",
};

export default querystringParameters;
