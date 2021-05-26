#!/bin/zsh

declare -A -r SERVICES=(
    [books]=4001
    [reviews]=4002
    [users]=4003
    [search]=4004
    [signatures]=4005
)

for service port in ${(kv)SERVICES}
do
    echo '==========' $service '=========='
    rover subgraph introspect http://localhost:$port > $service/subgraph.graphql
done

echo '==========' supergraph '=========='
rover supergraph compose --config ./supergraph-config.yml > supergraph.graphql
