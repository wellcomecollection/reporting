import * as conversionConfig from "./metrics-conversion-prod";
import * as similarityConfig from "./metrics-similarity-prod";

import { Client } from "@elastic/elasticsearch";
import dotenv from "dotenv";
import prompts from "prompts";

dotenv.config();

const client = new Client({
  cloud: {
    id: process.env.ELASTIC_CLOUD_ID!,
  },
  auth: {
    username: process.env.ELASTIC_USERNAME!,
    password: process.env.ELASTIC_PASSWORD!,
  },
});

async function main() {
  const { dataStreamName } = await prompts([
    {
      type: "select",
      name: "dataStreamName",
      message: "Which data stream's mapping would you like to update?",
      choices: [
        { title: "metrics-conversion-prod", value: "metrics-conversion-prod" },
        { title: "metrics-similarity-prod", value: "metrics-similarity-prod" },
      ],
    },
  ]);

  let config;
  if (dataStreamName === "metrics-conversion-prod") {
    config = conversionConfig;
  } else if (dataStreamName === "metrics-similarity-prod") {
    config = similarityConfig;
  } else {
    throw new Error("Invalid data stream name");
  }

  // create component template
  await client.cluster
    .putComponentTemplate({
      name: config.componentTemplate.name,
      ...config.componentTemplate.body,
    })
    .catch((err) => {
      console.error(err.meta.body);
      throw err;
    });

  // create index template
  await client.indices
    .putIndexTemplate({
      name: config.indexTemplate.name,
      ...config.indexTemplate.body,
    })
    .catch((err) => {
      console.error(err.meta.body);
      throw err;
    });

  // update existing mapping
  await client.indices.putMapping({
    index: config.indexTemplate.indexPatternName,
    ...config.componentTemplate.body.template.mappings,
  });
}

main();
