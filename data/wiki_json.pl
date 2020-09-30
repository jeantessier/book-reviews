sub WikiContentsAsJson {
    local (@lines) = @_;

    chomp(@lines);
    local ($result) = join('\n', @lines);

    return &JsonText($result);
}

sub JsonList {
    local (@params) = @_;

    return "[" . join(",", @params) . "]";
}

sub JsonRecord {
    local (%params) = @_;

    return "{" . join(",", map { &JsonText($_) . ":" . $params{$_} } keys %params) . "}";
}

sub JsonText {
    local ($text) = @_;

    $text =~ s/([^\\])"/\1\\"/g;

    return "\"" . $text . "\"";
}

1;
