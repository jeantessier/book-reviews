#!/usr/bin/perl

use File::Slurp;

require 'wiki_sql.pl';

$DIRNAME = ".";

if ($0 =~ /(\w+)_grails_mysql\./) {
    $DOCUMENT = $1;
}

$USER_ID = 1;
$BOOK_ID = 1;
$TITLE_ID = 1;

print &DocumentAsMysql($DOCUMENT);

sub DocumentAsMysql {
    local ($document) = @_;

    return &DocumentPartsAsMysql($document) . "\n";
}

sub DocumentPartsAsMysql {
    local ($document) = @_;

    open(FILEHANDLE, "$DIRNAME/${document}_grails_mysql_schema.sql");
    local (@schema_lines) = <FILEHANDLE>;
    close(FILEHANDLE);
    local ($schema_stmts) = join("", @schema_lines);

    open(FILEHANDLE, "$DIRNAME/${document}_grails_mysql_users.sql");
    local (@user_lines) = <FILEHANDLE>;
    close(FILEHANDLE);
    local ($user_stmts) = join("", @user_lines);

    opendir(DIRHANDLE, $DIRNAME);
    local (@files) = grep { /^${document}_\d{4}-\d{2}-\d{2}.txt$/ } readdir(DIRHANDLE);
    closedir(DIRHANDLE);

    local ($comments) = "--\n-- Books\n--";

    local (@book_stmts) = map { &DocumentPartAsMysql("$DIRNAME/$_") } reverse sort @files;

    return join("\n\n", $schema_stmts, $user_stmts, $comments, @book_stmts);
}

sub DocumentPartAsMysql {
    local ($filename) = @_;
    local ($user_id) = $USER_ID;
    local ($book_id) = $BOOK_ID++;

    open(FILEHANDLE, $filename);
    local (@lines) = <FILEHANDLE>;
    close(FILEHANDLE);

    local (%meta_data, @titles, @authors, @years);

    do {
        $line = shift(@lines);
        chomp $line;

        if ($line =~ /(\w+):\s*(.*)/) {
            local ($key, $value) = ($1, $2);

            if ($key eq "title") {
                push @titles, $value;
            } elsif ($key eq "author") {
                push @authors, $value;
            } elsif ($key eq "year") {
                push @years, $value;
            } else {
                $meta_data{$key} = $value;
            }
        }
    } until ($line =~ /^\s*$/);

    local ($title) = $titles[0];
    if ($title =~ /\[\[([^\]]*)\]\[_(.*)_\]\]/) {
        $title = $2;
    } elsif ($title =~ /\[\[([^\]]*)\]\[(.*)\]\]/) {
        $title = $2;
    }

    local ($book_stmt) = "-- " . $title . "\n\ninsert into\n    book(id, name, publisher)\nvalues\n    (" . $book_id . ", " . &SqlText($meta_data{"name"}) . ", " . &SqlText($meta_data{"publisher"}) . ");";

    local (@author_stmts) = map {
        "insert into\n    book_authors(book_id, authors_string)\nvalues\n    (" . $book_id . ", " . &SqlText($_) . ");"
    } @authors;

    local (@year_stmts) = map {
        "insert into\n    book_years(book_id, years_string)\nvalues\n    (" . $book_id . ", " . &SqlText($_) . ");"
    } @years;

    local (@title_stmts) = map {
        local ($title_id) = $TITLE_ID++;
        if (/\[\[([^\]]*)\]\[_(.*)_\]\]/) {
            "insert into\n    title(id, book_id, title, link)\nvalues\n    (" . $title_id . ", " . $book_id . ", " . &SqlText($2) . ", " . &SqlText($1) . ");";
        } elsif (/\[\[([^\]]*)\]\[(.*)\]\]/) {
            "insert into\n    title(id, book_id, title, link)\nvalues\n    (" . $title_id . ", " . $book_id . ", " . &SqlText($2) . ", " . &SqlText($1) . ");";
        } else {
            "insert into\n    title(id, book_id, title)\nvalues\n    (" . $title_id . ", " . $book_id . ", " . &SqlText($_) . ");";
        }
    } @titles;

    local ($review_stmt);
    if (exists $meta_data{"stop"}) {
        $review_stmt = "insert\n    into review(book_id, reviewer_id, body, start, stop)\nvalues\n    (" . $book_id . ", " . $user_id . ", " . &WikiContentsAsSql(@lines) . ", " . &SqlText($meta_data{"start"}) . ", " . &SqlText($meta_data{"stop"}) . ");";
    } elsif (exists $meta_data{"start"}) {
        $review_stmt = "insert\n    into review(book_id, reviewer_id, body, start)\nvalues\n    (" . $book_id . ", " . $user_id . ", " . &WikiContentsAsSql(@lines) . ", " . &SqlText($meta_data{"start"}) . ");";
    } else {
        $review_stmt = "insert\n    into review(book_id, reviewer_id, body)\nvalues\n    (" . $book_id . ", " . $user_id . ", " . &WikiContentsAsSql(@lines) . ");";
    }

    return join("\n\n", $book_stmt, @author_stmts, @year_stmts, @title_stmts, $review_stmt);
}