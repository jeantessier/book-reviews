#!/usr/bin/perl

use File::Slurp;

require '../data/wiki_sql.pl';

$DIRNAME = "../data";

if ($0 =~ /(\w+)_rails_mysql\./) {
    $DOCUMENT = $1;
}

$USER_ID = 1;
$BOOK_ID = 1;

print &DocumentAsMysql($DOCUMENT);

sub DocumentAsMysql {
    local ($document) = @_;

    return &DocumentPartsAsMysql($document) . "\n";
}

sub DocumentPartsAsMysql {
    local ($document) = @_;

    open(FILEHANDLE, "${document}_rails_mysql_schema.sql");
    local (@schema_lines) = <FILEHANDLE>;
    close(FILEHANDLE);
    local ($schema_stmts) = join("", @schema_lines);

    open(FILEHANDLE, "${document}_rails_mysql_data.sql");
    local (@user_lines) = <FILEHANDLE>;
    close(FILEHANDLE);
    local ($user_stmts) = join("", @user_lines);

    opendir(DIRHANDLE, $DIRNAME);
    local (@files) = grep { /^${document}_\d{4}-\d{2}-\d{2}(_\w)?.txt$/ } readdir(DIRHANDLE);
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

    local ($book_stmt) = "-- " . $title . "\n\ninsert into\n    books(id, name, publisher, created_at, updated_at)\nvalues\n    (" . $book_id . ", " . &SqlText($meta_data{"name"}) . ", " . &SqlText($meta_data{"publisher"}) . ", now(), now());";

    local ($author_order) = 1;
    local (@author_stmts) = map {
        "insert into\n    book_authors(book_id, name, book_authors.order)\nvalues\n    (" . $book_id . ", " . &SqlText($_) . ", " . $author_order++ . ");"
    } @authors;

    local ($year_order) = 1;
    local (@year_stmts) = map {
        "insert into\n    book_years(book_id, year, book_years.order)\nvalues\n    (" . $book_id . ", " . &SqlText($_) . ", " . $year_order++ . ");"
    } @years;

    local ($title_order) = 1;
    local (@title_stmts) = map {
        if (/\[\[([^\]]*)\]\[_(.*)_\]\]/) {
            "insert into\n    book_titles(book_id, title, link, book_titles.order)\nvalues\n    (" . $book_id . ", " . &SqlText($2) . ", " . &SqlText($1) . ", " . $title_order++ . ");";
        } elsif (/\[\[([^\]]*)\]\[(.*)\]\]/) {
            "insert into\n    book_titles(book_id, title, link, book_titles.order)\nvalues\n    (" . $book_id . ", " . &SqlText($2) . ", " . &SqlText($1) . ", " . $title_order++ . ");";
        } else {
            "insert into\n    book_titles(book_id, title, book_titles.order)\nvalues\n    (" . $book_id . ", " . &SqlText($_) . ", " . $title_order++ . ");";
        }
    } @titles;

    local ($review_stmt);
    if (exists $meta_data{"stop"}) {
        $review_stmt = "insert\n    into reviews(book_id, reviewer_id, body, start, stop, created_at, updated_at)\nvalues\n    (" . $book_id . ", " . $user_id . ", " . &WikiContentsAsSql(@lines) . ", " . &SqlText($meta_data{"start"}) . ", " . &SqlText($meta_data{"stop"}) . ", now(), now());";
    } elsif (exists $meta_data{"start"}) {
        $review_stmt = "insert\n    into reviews(book_id, reviewer_id, body, start, created_at, updated_at)\nvalues\n    (" . $book_id . ", " . $user_id . ", " . &WikiContentsAsSql(@lines) . ", " . &SqlText($meta_data{"start"}) . ", now(), now());";
    } else {
        $review_stmt = "insert\n    into reviews(book_id, reviewer_id, body, created_at, updated_at)\nvalues\n    (" . $book_id . ", " . $user_id . ", " . &WikiContentsAsSql(@lines) . ", now(), now());";
    }

    return join("\n\n", $book_stmt, @author_stmts, @year_stmts, @title_stmts, $review_stmt);
}
