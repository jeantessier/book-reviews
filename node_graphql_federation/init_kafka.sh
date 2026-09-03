#!/bin/sh

readonly IMAGE_MODE=${1:-local}
shift

readonly COMPOSE_FILE=docker-compose.${IMAGE_MODE}.yml
if [[ ! -r $COMPOSE_FILE ]]
then
    echo Unknown mode: $IMAGE_MODE
    echo Compose file $COMPOSE_FILE not found
    echo Available choices:
    for f in $(ls docker-compose*.yml | perl -n -e 'print $1 . "\n" if /docker-compose.(.*).yml/ && $1 !~ /override/')
    do
      echo "    " $f
    done
    exit 1
fi

readonly TOPICS=(
    books
    reviews
    users
    searches
)

for topic in ${TOPICS[*]}
do
    docker compose --file $COMPOSE_FILE --file docker-compose.override.yml exec \
        kafka \
        /opt/kafka/bin/kafka-topics.sh \
        --bootstrap-server kafka:9092 \
        --create \
        --topic book-reviews.$topic \
        $*
done
