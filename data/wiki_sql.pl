sub WikiContentsAsSql {
    local (@lines) = @_;

    chomp(@lines);
    local ($result) = join('\n', @lines);

    return &SqlText($result);
}

sub SqlText {
    local ($text) = @_;

    $text =~ s/'/''/g;

    return "\'" . $text . "\'";
}

1;
