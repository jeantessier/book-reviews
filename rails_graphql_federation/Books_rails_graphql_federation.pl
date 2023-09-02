#!/usr/bin/perl

use File::Slurp;

require '../data/wiki_json.pl';

$DIRNAME = "../data";

if ($0 =~ /(\w+)_rails_graphql_federation\./) {
    $DOCUMENT = $1;
}

sub DoubleEscape {
    local ($text) = @_;

    $text =~ s/`/\\`/g;
    $text =~ s/\\"/\\\\\\"/g;

    return $text;
}

print &DocumentAsShell($DOCUMENT);

sub DocumentAsShell {
    local ($document) = @_;

    return &DocumentPartsAsShell($document) . "\n";
}

sub DocumentPartsAsShell {
    local ($document) = @_;

    open(FILEHANDLE, "${document}_rails_graphql_federation_helpers.sh");
    local (@helper_lines) = <FILEHANDLE>;
    close(FILEHANDLE);
    local ($helper_stmts) = join("", @helper_lines);

    open(FILEHANDLE, "${document}_rails_graphql_federation_users.sh");
    local (@user_lines) = <FILEHANDLE>;
    close(FILEHANDLE);
    local ($user_stmts) = join("", @user_lines);

    opendir(DIRHANDLE, $DIRNAME);
    local (@files) = grep { /^${document}_\d{4}-\d{2}-\d{2}(_\w)?.md$/ } readdir(DIRHANDLE);
    closedir(DIRHANDLE);

    local ($comments) = "#\n# Books\n#";

    local (@book_stmts) = map { &DocumentPartAsMysql("$DIRNAME/$_") } reverse sort @files;

    return join("\n\n", $helper_stmts, $user_stmts, $comments, @book_stmts);
}

sub DocumentPartAsMysql {
    local ($filename) = @_;

    open(FILEHANDLE, $filename);
    local (@lines) = <FILEHANDLE>;
    close(FILEHANDLE);

    local (%meta_data, @titles, @authors, @years);

    do {
        $line = shift(@lines);
        chomp $line;

        if ($line =~ /(?<key>\w+):\s*(?<value>.*)/) {
            if ($+{key} eq "title") {
                push @titles, $+{value};
            } elsif ($+{key} eq "author") {
                push @authors, $+{value};
            } elsif ($+{key} eq "year") {
                push @years, $+{value};
            } else {
                $meta_data{$+{key}} = $+{value};
            }
        }
    } until ($line =~ /^\s*$/);

    local ($title) = $titles[0];
    if ($title =~ /\[(?<title>.*)\]\((?<link>.*)\)/) {
        $title = $+{title};
    }

    local ($book_comment) = "# Book: " . $title . "\necho Adding " . &JsonText($title) . " ...";

    local ($titles_list) = &JsonList(map {
        if (/\[(?<title>.*)\]\((?<link>.*)\)/) {
            &JsonRecord(
                title => &JsonText($+{title}),
                link => &JsonText($+{link}),
            );
        } else {
            &JsonRecord(
                title => &JsonText($_),
                link => "null",
            );
        }
    } @titles);
    local ($authors_list) = &JsonList(map { &JsonText($_) } map { s/"/\\\\\\"/g; $_ } @authors);
    local ($years_list) = &JsonList(map { &JsonText($_) } @years);

    local ($book_stmt) = "book_id=\$(addBook " . &JsonText($meta_data{"name"}) . " " . &JsonText($titles_list) . " " . &JsonText($meta_data{"publisher"}) . " " . &JsonText($authors_list) . " " . &JsonText($years_list) . ")\n\necho '    ' Book \$book_id";

    local ($review_stmt);
    if (exists $meta_data{"stop"}) {
        $review_stmt = "review_id=\$(addReview \$jean_id \$book_id " . &DoubleEscape(&WikiContentsAsJson(@lines)) . " " . &JsonText($meta_data{"start"}) . " " . &JsonText($meta_data{"stop"}) . ")\n\necho '    ' Review \$review_id";
    } elsif (exists $meta_data{"start"}) {
        $review_stmt = "review_id=\$(addReview \$jean_id \$book_id " . &DoubleEscape(&WikiContentsAsJson(@lines)) . " " . &JsonText($meta_data{"start"}) . ")\n\necho '    ' Review \$review_id";
    } else {
        $review_stmt = "review_id=\$(addReview \$jean_id \$book_id " . &DoubleEscape(&WikiContentsAsJson(@lines)) . ")\n\necho '    ' Review \$review_id";
    }

    return join("\n\n", $book_comment, $book_stmt, $review_stmt);
}
