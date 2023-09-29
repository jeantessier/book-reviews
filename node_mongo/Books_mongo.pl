#!/usr/bin/perl

require '../data/wiki_json.pl';

$DIRNAME = "../data";

if ($0 =~ /(\w+)_mongo\./) {
    $DOCUMENT = $1;
}

print &DocumentAsMongo($DOCUMENT);

sub DocumentAsMongo {
    local ($document) = @_;

    return &DocumentPartsAsMongo($document) . "\n";
}

sub DocumentPartsAsMongo {
    local ($document) = @_;

    opendir(DIRHANDLE, $DIRNAME);
    local (@files) = grep { /^${document}_\d{4}-\d{2}-\d{2}(_\w)?.md$/ } readdir(DIRHANDLE);
    closedir(DIRHANDLE);

    local ($drop_stmt) = join("\n", map { "db.$_.drop()" } "books", "reviews", "users");
    local ($time_stmt) = "var initTime = new Date()";

    local ($users_stmt) = "var users = db.users.insertMany(" .
        &JsonList(
            &JsonRecord(
                name => &JsonText("Administrator"),
                email => &JsonText("admin\@bookreviews.com"),
                hash => &JsonText("0123456789abcdef9842ed9614143f40ca11e5c24da1d1a115087efc6dc2205ce46ee788737dfe06d02ad5d2c5ba67b1ef571dd00bd50136ba2ed5e9f6301e0f"),
                salt => &JsonText("0123456789abcdef0123456789abcdef"),
                roles => &JsonList(&JsonText("ROLE_ADMIN"), &JsonText("ROLE_USER")),
                __v => 0,
                createdAt => "initTime",
                updatedAt => "initTime",
            ),
            &JsonRecord(
                name => &JsonText("Jean Tessier"),
                email => &JsonText("jean\@jeantessier.com"),
                hash => &JsonText("0123456789abcdef9842ed9614143f40ca11e5c24da1d1a115087efc6dc2205ce46ee788737dfe06d02ad5d2c5ba67b1ef571dd00bd50136ba2ed5e9f6301e0f"),
                salt => &JsonText("0123456789abcdef0123456789abcdef"),
                roles => &JsonList(&JsonText("ROLE_USER")),
                __v => 0,
                createdAt => "initTime",
                updatedAt => "initTime",
            ),
        ). ")";

    local (@book_stmts) = map { &DocumentPartAsMongo("$DIRNAME/$_") } reverse sort @files;

    return join("\n\n", $drop_stmt, $time_stmt, $users_stmt, @book_stmts);
}

sub DocumentPartAsMongo {
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

    local ($book_stmt) = "var book = db.books.insertOne(" .
        &JsonRecord(
            name => &JsonText($meta_data{"name"}),
            authors => &JsonList(map { &JsonText($_) } @authors),
            titles => &JsonList(map {
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
            } @titles),
            publisher => &JsonText($meta_data{"publisher"}),
            years => &JsonList(map { &JsonText($_) } @years),
            __v => 0,
            createdAt => "initTime",
            updatedAt => "initTime",
        ) . ")";

    local ($review_stmt) = "db.reviews.insertOne(" .
        &JsonRecord(
            body => &WikiContentsAsJson(@lines),
            start => &JsonText($meta_data{"start"}),
            stop => (exists $meta_data{"stop"}) ? &JsonText($meta_data{"stop"}) : "null",
            book => "book.insertedId",
            reviewer => "users.insertedIds[1]",
            __v => 0,
            createdAt => "initTime",
            updatedAt => "initTime",
        ) . ")";

    return join("\n", $book_stmt, $review_stmt);
}
