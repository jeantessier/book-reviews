#!/bin/sh

for service in books reviews users search signatures jwts
do
    echo '==========' $service '=========='
    (cd $service; bundle outdated)
done

echo '========== gateway =========='
(cd gateway; npm outdated)
