#!/bin/sh

readonly BINDIR=$(dirname $0)

docker compose --file docker-compose.yml --file docker-compose.override.yml stop
docker compose --file docker-compose.yml --file docker-compose.override.yml up -d

echo Waiting for servers to start ...
docker compose --file docker-compose.yml --file docker-compose.override.yml logs --follow --tail 2 gateway | while read line
do
  if [[ $line =~ 'Server ready at' ]]
  then
    break
  fi
done

$BINDIR/seed.sh
