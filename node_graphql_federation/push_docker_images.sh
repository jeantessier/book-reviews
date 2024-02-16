#!/bin/sh

readonly SERVICES=(
    books
    reviews
    users
    search
    signatures
    jwts
    gateway
)

echo Building images ...
docker compose \
    --file docker-compose.containers.yml \
    --file docker-compose.override.yml \
    build --no-cache

for service in ${SERVICES[*]}
do
    version=$(perl -n -e 'print $1 if /"version": "(.*)"/' $service/package.json)

    echo Tagging latest $service as $version ...
    docker image tag \
        jeantessier/book_reviews-node_graphql_federation-${service}:latest \
        jeantessier/book_reviews-node_graphql_federation-${service}:${version}

    echo Uploading $service ...
    docker image push jeantessier/book_reviews-node_graphql_federation-${service}:latest
    docker image push jeantessier/book_reviews-node_graphql_federation-${service}:${version}
done
