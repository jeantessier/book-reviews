#!/bin/sh

readonly SERVICES=(
    books:4001
    reviews:4002
    users:4003
    search:4004
    signatures:4005
    jwts:4006
)

for service in ${SERVICES[*]}
do
    echo '==========' ${service%%:*} '=========='
    rover subgraph introspect http://localhost:${service#*:} > ${service%%:*}/subgraph.graphql
done

echo '==========' supergraph '=========='
rover supergraph compose --config ./supergraph-config.yml > supergraph.graphql
