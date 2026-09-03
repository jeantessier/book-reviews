# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A sample book-reviews app demonstrating GraphQL federation. It's an npm workspaces
monorepo of small, mostly single-file Node microservices, each an Apollo Server
subgraph, wired together by an Apollo Gateway and kept in sync with each other
asynchronously through Kafka rather than direct service-to-service calls.

Workspaces (declared in root `package.json`):
- `books`, `reviews`, `users`, `search`, `signatures`, `jwts` — the six subgraphs
  described in `README.md`.
- `vector_indexer`, `vector_search` — newer services (not yet documented in
  README.md) that mirror `books`/`reviews`/`users`/`searches` Kafka topics into a
  MongoDB Atlas vector store (via LangChain + Google Generative AI embeddings) and
  replay search queries against it for comparison. Not part of the federated
  schema (no GraphQL server) — pure Kafka consumers.
- `gateway` — the Apollo Gateway composing the six GraphQL subgraphs.
- `kafka` — shared library (`sendMessage`, `startConsumer`, `groupId`) published
  to npm and depended on by every service that talks to Kafka.

## Commands

```bash
npm install --workspaces                  # install all workspace deps

npm start --workspace <service>           # run one service, e.g. --workspace books
npm start --workspace gateway             # run the gateway (needs subgraphs already up)

DEBUG=1 npm start --workspace <service>   # verbose internal-state logging
```

There are no automated tests (`npm test` in every service is a stub that exits 1).
There's no lint/build step; services run directly via `node`.

Each service needs a local `.env` (copy `.env.template`); `JWT_SECRET` must be
identical across all services that verify JWTs. See `README.md` for the full
setup (Kafka/Zipkin via Docker Compose, seeding, re-signing bootstrap JWTs).

Bringing up everything with Docker Compose, seeding data, extracting the
federated schema, and Kafka consumer-group maintenance are all documented in
`README.md` — read it before reinventing those workflows; don't duplicate the
sample GraphQL queries/mutations from there, they're a good reference for
exercising the API end-to-end.

## Architecture

**Each subgraph service owns an in-memory `Map` as its only datastore.** There is
no database. State is rebuilt by replaying Kafka topics from the beginning on
startup (`startConsumer(..., fromBeginning: true)`), and mutations write to Kafka
first — the in-memory map is updated only when the service consumes its own
message back off the topic. This means:
- A mutation resolver never mutates the map directly; it calls `sendMessage(topic, { type, ...payload }, headers)` and returns the payload optimistically.
- `startConsumer({ groupId, topic, messageHandlers, defaultHandler, postCallback })` dispatches by the message's `type` field to a handler that updates the local map (add/update/remove per entity).
- Kafka topics are named `book-reviews.<entity>` (e.g. `book-reviews.books`, `book-reviews.reviews`, `book-reviews.users`, `book-reviews.searches`, `book-reviews.views`). A `topic` can be a regex to subscribe to several at once (e.g. `search`, `vector_indexer` listen on `/book-reviews.(books|reviews|users)/`).
- `search` also builds its own inverted word index by consuming books/reviews/users events, and logs every `search` query + results to `book-reviews.searches` for later replay/analysis (see `search`'s `queryPlan` field, which exposes the scoring internals, and `vector_search`, which replays those logged queries against the vector store for comparison).

**Federation**: subgraphs use Apollo Federation 1 conventions (`@key(fields: "id")`
on an owned type, `extend type X @key(...) { id: ID! @external }` plus
`__resolveReference` on a referencing subgraph, e.g. `reviews` and `signatures`
extend `User`, `reviews` extends `Book`). The gateway (`gateway/index.js`) composes
subgraphs at startup with `IntrospectAndCompose` (fine for this sample, called out
in-code as not recommended for production) and forwards the `Authorization` and
`X-Request-Id` headers to subgraphs via a custom `RemoteGraphQLDataSource`.

**Auth**: JWTs are signed/verified with a shared `JWT_SECRET`. `jwts` issues them
on login; every other subgraph independently verifies the bearer token itself
(`getCurrentUser(req)` in each service's context function) and checks
`currentUser.roles` (e.g. `ROLE_ADMIN`) in mutation resolvers — there's no
central auth gateway/middleware.

**Cross-cutting concerns repeated per service** (same shape in every
`<service>/index.js` and `<service>/open-telemetry.js`, so copy the pattern from
a sibling service rather than designing a new one):
- OpenTelemetry is bootstrapped via `--require ./open-telemetry.js` before
  `index.js` loads (see each service's `start` script), exporting traces to
  Zipkin (`ZIPKIN_EXPORTER_URL`) under `OPEN_TELEMETRY_SERVICE_NAME`.
- Every resolver/request logs a `====...====` banner with timestamp and request
  ID, then query/operationName/variables; `DEBUG=1` additionally dumps the
  service's in-memory map/index contents on every request and Kafka message.
- `context.requestId` comes from the incoming `X-Request-Id` header or a fresh
  UUID, and is threaded through as a Kafka message header (`request_id`) so a
  mutation and the Kafka message it produces can be correlated in logs/traces.

## Gotchas

- The stray `book-reviews.*.json` files, `*.log` files, and `dependencies.rb` at
  the repo root are local scratch/output, not checked-in fixtures — don't treat
  them as source of truth for schemas or data.
- Because every service replays Kafka from the beginning on boot, resetting the
  Kafka volume (see README's Kafka Maintenance section) wipes all application
  state, not just message backlog.
