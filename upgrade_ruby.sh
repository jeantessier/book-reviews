#!/bin/sh

readonly FROM_VERSION=3.4.6
readonly TO_VERSION=4.3.7

find . -name .ruby-version -exec perl -pi -e "s/${FROM_VERSION}/${TO_VERSION}/" \{\} +
for d in $(dirname $(find . -name .ruby-version))
do
    echo "==========" $d "=========="
    (
        cd $d
        bundle update --bundler
        bundle update --all
    )
done
