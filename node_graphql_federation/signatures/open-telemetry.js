// Import required symbols
const { NodeSDK } = require('@opentelemetry/sdk-node')
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node')
const { resourceFromAttributes } = require('@opentelemetry/resources')
const { ATTR_SERVICE_NAME } = require('@opentelemetry/semantic-conventions')
const { GraphQLInstrumentation } = require ('@opentelemetry/instrumentation-graphql')
const { ZipkinExporter } = require('@opentelemetry/exporter-zipkin')

require('dotenv').config()

const sdk = new NodeSDK({
    resource: resourceFromAttributes({
        [ATTR_SERVICE_NAME]: process.env.OPEN_TELEMETRY_SERVICE_NAME,
    }),
    traceExporter: new ZipkinExporter({
        url: process.env.ZIPKIN_EXPORTER_URL,
    }),
    instrumentations: [
        getNodeAutoInstrumentations(),
        new GraphQLInstrumentation(),
    ],
})

sdk.start()
