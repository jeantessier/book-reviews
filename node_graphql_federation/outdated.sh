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

for service in ${SERVICES[*]}
do
    echo '==========' $service '=========='
    (
        cd $service
        npm outdated
    )
done
