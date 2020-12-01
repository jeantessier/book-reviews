#!/bin/sh

readonly BINDIR=$(dirname $0)

docker-compose stop
docker-compose up -d

echo Waiting for servers to start ...
docker-compose logs --follow --tail 100 gateway | while read line
do
  if [[ $line =~ 'Server ready at' ]]
  then
    break
  fi
done

$BINDIR/seed.sh
