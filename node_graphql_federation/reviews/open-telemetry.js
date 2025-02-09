// Import required symbols
const { Resource } = require('@opentelemetry/resources')
const { SimpleSpanProcessor, ConsoleSpanExporter } = require ("@opentelemetry/sdk-trace-base")
const { NodeTracerProvider } = require("@opentelemetry/sdk-trace-node")
const { registerInstrumentations } = require('@opentelemetry/instrumentation')
const { HttpInstrumentation } = require ('@opentelemetry/instrumentation-http')
const { ExpressInstrumentation } = require ('@opentelemetry/instrumentation-express')
const { GraphQLInstrumentation } = require ('@opentelemetry/instrumentation-graphql')
const { ZipkinExporter } = require("@opentelemetry/exporter-zipkin")

// Register server-related instrumentation
registerInstrumentations({
    instrumentations: [
        new HttpInstrumentation(),
        new ExpressInstrumentation(),
        new GraphQLInstrumentation(),
    ]
})

// Initialize provider and identify this particular service
const provider = new NodeTracerProvider({
    resource: Resource.default().merge(new Resource({
        "service.name": process.env.OPEN_TELEMETRY_SERVICE_NAME,
    })),
})

// Configure a test exporter to print all traces to the console
// const consoleExporter = new ConsoleSpanExporter();
// provider.addSpanProcessor(
//     new SimpleSpanProcessor(consoleExporter)
// )

// Configure an exporter that pushes all traces to Zipkin
// (This assumes Zipkin is running on localhost at the
// default port of 9411)
const zipkinExporter = new ZipkinExporter({
    // url: set_this_if_not_running_zipkin_locally
    url: process.env.ZIPKIN_EXPORTER_URL,
})
provider.addSpanProcessor(
    new SimpleSpanProcessor(zipkinExporter)
)

// Register the provider to begin tracing
provider.register()
