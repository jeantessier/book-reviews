#!/usr/bin/env ruby -n

#
# Extract HTML entities from inputs.
#
#     html_entities.rb file1 file2 ...
#
# To get an entity histogram:
#
#     ./html_entities.rb Books_*.md | cut -f 1 | sort | uniq --count | sort --numeric-sort --reverse
#

BEGIN {
  REGEX = /(&\w+;)/
}

$_.scan(REGEX) do |entity|
  puts [ entity, ARGF.filename, ARGF.file.lineno ].join("\t")
end

