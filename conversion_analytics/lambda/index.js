'use-strict'
const { Client } = require('@elastic/elasticsearch')

let esClient
function setEsClient(credentials) {
  esClient = new Client({
    node: credentials.url,
    auth: {
      username: credentials.username,
      password: credentials.password
    }
  })
}

const AWS = require('aws-sdk')
const region = 'eu-west-1'
const secretName = 'prod/SearchLogger/es_details'
const secretsManager = new AWS.SecretsManager({
  region: region
})

async function processEvent(event, context, callback) {
  const operations = event.Records.map((record) => {
    // eslint-disable-next-line node/no-deprecated-api
    const payload = new Buffer(record.kinesis.data, 'base64').toString('utf-8')
    try {
      const json = JSON.parse(payload)
      if (json.event === 'conversion') {
        return parseConversion(json)
      } else if (json.event === 'similarity') {
        return parseSimilarity(json)
      } else {
        console.info(`Ignoring event ${json.event}`)
      }
    } catch (e) {
      console.error(e, payload)
    }
    return undefined
  })
    .filter(Boolean)
    .reduce(function (acc, tuple) {
      return acc.concat(tuple)
    }, [])

  // Get only uniques
  const services = operations
    .map((b) => b.index && b.index._index)
    .filter(Boolean)
    .filter((service, i, arr) => arr.indexOf(service) === i)
    .join(', ')

  if (operations.length > 0) {
    const { body: bulkResponse } = await esClient.bulk({ body: operations })
    if (bulkResponse.errors) {
      console.log(
        'Error sending bulk to Elastic: ',
        JSON.stringify(bulkResponse, null, 2)
      )
    } else {
      console.log(
        `Success on services: ${services} with ${operations.length / 2} records`
      )
    }
  }
}

function deDotFieldNames(obj) {
  return Object.entries(obj).reduce((acc, [key, val]) => {
    return {
      ...acc,
      [key.replace(/\./g, '_')]: val
    }
  }, {})
}

function parseConversion(segmentEvent) {
  const {
    messageId,
    timestamp,
    anonymousId,
    properties: segmentProperties
  } = segmentEvent
  const esDoc = {
    '@timestamp': timestamp,
    anonymousId,
    session: segmentProperties.session,
    type: segmentProperties.type,
    source: segmentProperties.source,
    page: {
      ...segmentProperties.page,
      query: deDotFieldNames(segmentProperties.page.query)
    },
    properties: segmentProperties.properties
  }

  console.info(`Parsed conversion metric ${anonymousId}`)
  console.info(esDoc)
  return [
    {
      index: {
        _index: 'conversion',
        _id: messageId
      }
    },
    esDoc,
    {
      create: {
        _index: 'metrics-conversion-prod',
        _id: messageId
      }
    },
    esDoc
  ]
}
module.exports.parseConversion = parseConversion

function parseSimilarity(segmentEvent) {
  const {
    messageId,
    timestamp,
    anonymousId,
    properties: segmentProperties
  } = segmentEvent
  const esDoc = {
    '@timestamp': timestamp,
    anonymousId,
    session: segmentProperties.session,
    type: segmentProperties.type,
    source: segmentProperties.source,
    page: {
      ...segmentProperties.page
    },
    properties: segmentProperties.properties
  }

  console.info(`Parsed similarity metric ${anonymousId}`)
  console.info(esDoc)
  return [
    {
      create: {
        _index: 'metrics-similarity-prod',
        _id: messageId
      }
    },
    esDoc
  ]
}
module.exports.parseSimilarity = parseSimilarity

module.exports.handler = function (event, context) {
  if (esClient) {
    processEvent(event, context)
  } else {
    secretsManager.getSecretValue(
      { SecretId: secretName },
      function (err, data) {
        if (err) {
          console.info('Secrets Manager error')
          console.error(err)
        } else {
          console.info('Secrets Manager success')
          try {
            const esCredentials = JSON.parse(data.SecretString)
            setEsClient(esCredentials)
            processEvent(event, context)
          } catch (e) {
            console.error(
              'Secrets Manager error: `SecretString` was not a valid JSON string'
            )
          }
        }
      }
    )
  }
}
