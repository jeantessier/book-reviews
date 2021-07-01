#!/bin/sh

readonly SERVICES=(
    zookeeper
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
    echo press ENTER to start $service
    read
    docker compose up -d $service
done
