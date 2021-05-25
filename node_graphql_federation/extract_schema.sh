#!/bin/sh

echo '==========' books '=========='
(cd books; rover subgraph introspect http://localhost:4001 > subgraph.graphql)
echo '==========' reviews '=========='
(cd reviews; rover subgraph introspect http://localhost:4002 > subgraph.graphql)
echo '==========' users '=========='
(cd users; rover subgraph introspect http://localhost:4003 > subgraph.graphql)
echo '==========' search '=========='
(cd search; rover subgraph introspect http://localhost:4004 > subgraph.graphql)
echo '==========' signatures '=========='
(cd signatures; rover subgraph introspect http://localhost:4005 > subgraph.graphql)

echo '==========' supergraph '=========='
rover supergraph compose --config ./supergraph-config.yml > supergraph.graphql
