#!/bin/sh

readonly SERVICES=(
    books:3001
    reviews:3002
    users:3003
    search:3004
    signatures:3005
)

for service in ${SERVICES[*]}
do
    echo '==========' ${service%%:*} '=========='
    rover subgraph introspect http://localhost:${service#*:}/graphql > ${service%%:*}/subgraph.graphql
done

echo '==========' supergraph '=========='
rover supergraph compose --config ./supergraph-config.yml > supergraph.graphql
