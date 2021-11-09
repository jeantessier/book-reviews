#!/bin/sh

readonly SERVICES=(
    books:3001
    users:3003
)

for service in ${SERVICES[*]}
do
    echo '==========' ${service%%:*} '=========='
    rover subgraph introspect http://localhost:${service#*:}/graphql > ${service%%:*}/subgraph.graphql
done

echo '==========' supergraph '=========='
rover supergraph compose --config ./supergraph-config.yml > supergraph.graphql
