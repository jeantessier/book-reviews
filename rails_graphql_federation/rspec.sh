#!/bin/sh

readonly SERVICES=(
    books
    reviews
    users
    search
    signatures
    jwts
)

for service in ${SERVICES[*]}
do
    (
        cd $service
        if [[ -z "$*" ]]
        then
            echo '==========' $service '==========' bin/rspec
            bin/rspec
        else
            for spec in $*
            do
                if [[ -e ${spec%%:*} ]]
                then
                    echo '==========' $service '==========' bin/rspec $spec
                    bin/rspec $spec
                fi
            done
        fi
    )
done
