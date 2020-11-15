#!/bin/sh

docker-compose stop
docker-compose up -d

echo waiting for servers to start ...
docker-compose logs --follow --tail 100 gateway | while read line
do
  if [[ $line =~ 'Server ready at' ]]
  then
    break
  fi
done

./seed.sh
