import dotenv from 'dotenv'
import { Client } from '@elastic/elasticsearch'
import { indexPatternName } from './index_template'

dotenv.config()

const client = new Client({
  cloud: {
    id: process.env.ELASTIC_CLOUD_ID!
  },
  auth: {
    username: process.env.ELASTIC_USERNAME!,
    password: process.env.ELASTIC_PASSWORD!
  }
})

async function main () {
  const response = await client.updateByQuery({
    index: indexPatternName,
    wait_for_completion: false
  })

  console.info(response)
}

main()
