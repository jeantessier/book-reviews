#!/bin/sh

readonly SERVICES=(
    books
    reviews
    users
    search
    signatures
    gateway
)

for service in ${SERVICES[*]}
do
    echo '==========' $service '=========='
    (
        cd $service
        \rm -R node_modules package-lock.json
        npm install
    )
done
