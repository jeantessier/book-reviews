#!/usr/bin/perl

use File::Slurp;

require '../data/wiki_sql.pl';

$DIRNAME = "../data";

if ($0 =~ /(\w+)_grails_mysql\./) {
    $DOCUMENT = $1;
}

print &DocumentAsMysql($DOCUMENT);

sub DocumentAsMysql {
    local ($document) = @_;

    return &DocumentPartsAsMysql($document) . "\n";
}

sub DocumentPartsAsMysql {
    local ($document) = @_;

    open(FILEHANDLE, "${document}_grails_mysql_schema.sql");
    local (@schema_lines) = <FILEHANDLE>;
    close(FILEHANDLE);
    local ($schema_stmts) = join("", @schema_lines);

    open(FILEHANDLE, "${document}_grails_mysql_data.sql");
    local (@user_lines) = <FILEHANDLE>;
    close(FILEHANDLE);
    local ($user_stmts) = join("", @user_lines);

    opendir(DIRHANDLE, $DIRNAME);
    local (@files) = grep { /^${document}_\d{4}-\d{2}-\d{2}(_\w)?.md$/ } readdir(DIRHANDLE);
    closedir(DIRHANDLE);

    local ($comments) = "--\n-- Books\n--";

    local (@book_stmts) = map { &DocumentPartAsMysql("$DIRNAME/$_") } reverse sort @files;

    return join("\n\n", $schema_stmts, $user_stmts, $comments, @book_stmts);
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

    local ($book_stmt) = "-- " . $title . "\nselect " . &SqlText("Inserting " . $title . " ...") . " as '';\n\ninsert into\n    book(name, publisher, date_created, last_updated)\nvalues\n    (" . &SqlText($meta_data{"name"}) . ", " . &SqlText($meta_data{"publisher"}) . ", now(), now());\nset \@book_id = last_insert_id();";

    local (@author_stmts) = map {
        "insert into\n    book_authors(book_id, authors_string)\nvalues\n    (\@book_id, " . &SqlText($_) . ");"
    } @authors;

    local (@year_stmts) = map {
        "insert into\n    book_years(book_id, years_string)\nvalues\n    (\@book_id, " . &SqlText($_) . ");"
    } @years;

    local (@title_stmts) = map {
        if (/\[(?<title>.*)\]\((?<link>.*)\)/) {
            "insert into\n    title(book_id, title, link)\nvalues\n    (\@book_id, " . &SqlText($+{title}) . ", " . &SqlText($+{link}) . ");";
        } else {
            "insert into\n    title(book_id, title)\nvalues\n    (\@book_id, " . &SqlText($_) . ");";
        }
    } @titles;

    local ($review_stmt);
    if (exists $meta_data{"stop"}) {
        $review_stmt = "insert\n    into review(book_id, reviewer_id, body, start, stop, date_created, last_updated)\nvalues\n    (\@book_id, \@user_id, " . &WikiContentsAsSql(@lines) . ", " . &SqlText($meta_data{"start"}) . ", " . &SqlText($meta_data{"stop"}) . ", now(), now());";
    } elsif (exists $meta_data{"start"}) {
        $review_stmt = "insert\n    into review(book_id, reviewer_id, body, start, date_created, last_updated)\nvalues\n    (\@book_id, \@user_id, " . &WikiContentsAsSql(@lines) . ", " . &SqlText($meta_data{"start"}) . ", now(), now());";
    } else {
        $review_stmt = "insert\n    into review(book_id, reviewer_id, body, date_created, last_updated)\nvalues\n    (\@book_id, \@user_id, " . &WikiContentsAsSql(@lines) . ", now(), now());";
    }

    return join("\n\n", $book_stmt, @author_stmts, @year_stmts, @title_stmts, $review_stmt);
}
