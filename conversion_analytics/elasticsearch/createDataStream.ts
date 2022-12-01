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
      type: "multiselect",
      name: "dataStreamName",
      message: "Which data stream would you like to create?",
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

  // create ilm
  await client.ilm
    .putLifecycle({
      policy: config.ilm.name,
      body: config.ilm.body,
    })
    .catch((err) => {
      console.error(err.meta.body);
      throw err;
    });

  // create component template
  await client.cluster
    .putComponentTemplate({
      name: config.componentTemplate.name,
      body: config.componentTemplate.body,
    })
    .catch((err) => {
      console.error(err.meta.body);
      throw err;
    });

  // create index template
  await client.indices
    .putIndexTemplate({
      name: config.indexTemplate.name,
      body: config.indexTemplate.body,
    })
    .catch((err) => {
      console.error(err.meta.body);
      throw err;
    });

  // create data stream
  await client.indices
    .createDataStream({
      name: config.indexTemplate.indexPatternName,
    })
    .catch((err) => {
      console.error(err.meta.body);
      throw err;
    });
}

main();
