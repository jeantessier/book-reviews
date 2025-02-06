#!/bin/sh



echo 'Ruby'
echo '===='

for d in $(find $(find * -type d -prune) -name .ruby-version -exec dirname \{\} +)
do
    echo $(cat $d/.ruby-version) $d
done \
    | sort -n -r



echo ''



echo 'Rails'
echo '====='

for d in $(find $(find * -type d -prune) -name Gemfile.lock -exec dirname \{\} +)
do
    echo $(ruby -n -e 'puts $1 if / rails \((\S+)\)/' $d/Gemfile.lock) $d
done \
    | sort -n -r
