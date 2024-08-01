#!/bin/sh

readonly IMAGE_MODE=${1:-local}
shift

readonly COMPOSE_FILE=docker-compose.${IMAGE_MODE}.yml
if [[ ! -r $COMPOSE_FILE ]]
then
    echo Unknown mode: $IMAGE_MODE
    echo Compose file $COMPOSE_FILE not found
    exit 1
fi

readonly SERVICES=(
    kafka
    books
    reviews
    users
    search
    signatures
    jwts
    gateway
)

for service in ${SERVICES[*]}
do
    read -p "press ENTER to start $service "
    docker compose --file $COMPOSE_FILE --file docker-compose.override.yml up -d $service
done
