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
      message: "Which data stream would you like to update?",
      choices: [
        { title: "metrics-conversion-prod", value: "metrics-conversion-prod" },
        { title: "metrics-similarity-prod", value: "metrics-similarity-prod" },
      ],
    },
  ]);



  const response = await client.updateByQuery({
    index: dataStreamName,
    wait_for_completion: false,
  });

  console.info(response);
}

main();
