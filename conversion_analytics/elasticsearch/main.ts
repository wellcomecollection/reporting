import dotenv from 'dotenv'
import { Client } from '@elastic/elasticsearch'
import * as ilm from './ilm'
import * as componentTemplate from './component_template'
import * as indexTemplate from './index_template'

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



async function main() {
  // create ilm
  await client.ilm.putLifecycle({
    policy: ilm.name,
    body: ilm.body,
  }).catch(err => { console.error(err.meta.body); throw err; })
  
  // create component template
  await client.cluster.putComponentTemplate({
    name: componentTemplate.name,
    body: componentTemplate.body
  }).catch(err => { console.error(err.meta.body); throw err; })
  
  // create index template
  await client.indices.putIndexTemplate({
    name: indexTemplate.name,
    body: indexTemplate.body
  }).catch(err => { console.error(err.meta.body); throw err; })
  
  // create data stream
  await client.indices.createDataStream({
    name: indexTemplate.indexPatternName
  })
}

main()