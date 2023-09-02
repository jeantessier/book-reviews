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

    local ($drop_stmt) = join("\n", "db.book.drop();", "db.review.drop();", "db.user.drop();");
    local ($user_stmt) = "var user = db.user.insertOne(" . &JsonRecord(name => &JsonText("Jean Tessier"), username => &JsonText("jean\@jeantessier.com"), password => &JsonText("0123456789abcdef0123456789abcdef"), reviews => &JsonList(), dateCreated => "new Date()", lastUpdated => "new Date()") . ");";
    local (@book_stmts) = map { &DocumentPartAsMongo("$DIRNAME/$_") } reverse sort @files;

    return join("\n\n", $drop_stmt, $user_stmt, @book_stmts);
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

    local ($book_stmt) = "var book = db.book.insertOne(" .
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
            reviews => &JsonList(),
            dateCreated => "new Date()",
            lastUpdated => "new Date()",
        ) . ");";

    local ($review_stmt) = "var review = db.review.insertOne(" .
        &JsonRecord(
            body => &WikiContentsAsJson(@lines),
            start => "new Date(" . &JsonText($meta_data{"start"}) . ")",
            stop => (exists $meta_data{"stop"}) ? "new Date(" . &JsonText($meta_data{"stop"}) . ")" : "null",
            book => "book.insertedId",
            reviewer => "user.insertedId",
            dateCreated => "new Date()",
            lastUpdated => "new Date()",
        ) . ");";

    local ($user_review_stmt) = "db.user.updateOne(" .
        &JsonRecord("_id" => "user.insertedId") . "," .
        &JsonRecord("\$addToSet" => &JsonRecord(reviews => "review.insertedId")) . ");";

    local ($book_review_stmt) = "db.book.updateOne(" .
        &JsonRecord("_id" => "book.insertedId") . "," .
        &JsonRecord("\$addToSet" => &JsonRecord(reviews => "review.insertedId")) . ");";

    return join("\n", $book_stmt, $review_stmt, $user_review_stmt, $book_review_stmt);
}
