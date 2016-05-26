drop database if exists book_reviews;
create database book_reviews;

use book_reviews;

--
-- Schema
--

create table book (
    id bigint(20) not null auto_increment,
    version bigint(20) not null default 0,
    name varchar(512) not null,
    publisher varchar(1024) not null,
    primary key (id),
    unique key idx_name (name)
);

create table book_authors (
    book_id bigint(20) not null,
    authors_string varchar(1024) not null,
    key idx_book_id (book_id),
    constraint fk_book_author foreign key (book_id) references book(id)
);

create table book_years (
    book_id bigint(20) not null,
    years_string varchar(1024) not null,
    key idx_book_id (book_id),
    constraint fk_book_year foreign key (book_id) references book(id)
);

create table title (
    id bigint(20) not null auto_increment,
    version bigint(20) not null default 0,
    book_id bigint(20) not null,
    title varchar(1024) not null,
    link varchar(1024),
    primary key (id),
    key idx_book_id (book_id),
    constraint fk_title_book foreign key (book_id) references book(id)
);

create table user (
    id bigint(20) not null auto_increment,
    version bigint(20) not null default 0,
    name varchar(128) not null,
    email varchar(128) not null,
    password varchar(128) not null,
    salt varchar(32) not null,
    primary key (id),
    unique key (email)
);

create table review (
    id bigint(20) not null auto_increment,
    version bigint(20) not null default 0,
    book_id bigint(20) not null,
    reviewer_id bigint(20) not null,
    body longtext not null,
    start datetime not null,
    stop datetime,
    primary key (id),
    key idx_book_id (book_id),
    constraint fk_review_book foreign key (book_id) references book(id),
    key idx_reviewer_id (reviewer_id),
    constraint fk_review_user foreign key (reviewer_id) references user(id)
);

--
-- Users
--

-- Jean

insert into
    user(id, name, email, password, salt)
values
    (
        1,
        'Jean Tessier',
        'jean@jeantessier.com',
        '0123456789abcdef9842ed9614143f40ca11e5c24da1d1a115087efc6dc2205ce46ee788737dfe06d02ad5d2c5ba67b1ef571dd00bd50136ba2ed5e9f6301e0f',
        '0123456789abcdef0123456789abcdef'
    );

--
-- Books
--

-- Mortality

insert into
    book(id, name, publisher)
values
    (
        1,
        'Mortality',
        'Twelve (Hachette)'
    );

insert into
    book_authors(book_id, authors_string)
values
    (
        1,
        'Christopher Hitchens'
    );

insert into
    book_years(book_id, years_string)
values
    (
        1,
        '2012'
    );

insert into
    title(id, book_id, title, link)
values
    (
        1,
        1,
        'Mortality',
        'http://amzn.com/1455502758'
    );

insert into
    review(id, book_id, reviewer_id, body, start, stop)
values
    (
        1,
        1,
        1,
        '<p>Hitchens told his editor he would write about anything except sports.  So when he was diagnosed with cancer, he wrote about it.  And as he approached his own end, he kept on writing.  He takes us on an intimate ride along as he explores his attitude towards death.</p><p>Early on, when death is but a shadow on the distant horizon, Hitchens is more outward-facing.  He deals with religion and people wishing him well (and sometimes not).  As the book and his cancer progress, he sheds externalities and slowly gets more personal.</p><p>Breakdown by chapter:</p><ol><li>Diagnosis, dealing with the news, side effects of therapy.</li><li>People express their religious sentiments.  He''ll have none of it.</li><li>The medical establishment tries everything to fight the disease.  More false hopes.</li><li>People''s euphemisms to avoid talking about death.</li><li>Losing his voice strikes <i>really</i> close to home.  Voice and expression are at the core of existence.</li><li>How people choose to die.  How what almost kills him is <b>not</b> making him stronger.  Starts to yearn for the end.</li><li>Personal observations on pain and fear, in the face of torture ... or medical procedures.</li><li>Unfinished thoughts.  Fitting that at the end, even his mind comes apart.</li></ol><p>Hitchens mentions journalist John Diamond who also wrote a regular column about his experience with cancer, up to his death.  He mentions how his story "lacked compactness toward the end..."  He didn''t fall into the same trap.  The book is concise and to the point, a quick read that goes straight to the point.</p><p>On 2014-01-26, I came upon this New York Times article where Dr. Paul Kalanithi recounts <a target="_blank" href="http://nyti.ms/1eXxdlj">when he was diagnosed with lung cancer</a>.  He talks about the patient-doctor relationship and how focusing too much on survival rates can make you miss the important things in life.  I can''t help but wonder at the timing coincidence of seeing this article just as I finished reading Mortality.  Is it that lots of people are currently contemplating their own mortality these days?  Or is it me who is more sensitized to it because I just read this book?</p><p>On 2015-02-19, I came upon another New York Times article where <a target="_blank" href="http://nyti.ms/17u5LNP">Dr. Oliver Sacks talks about his cancer diagnosis</a>.  I find it interesting that at this point, he is looking back upon his life.  Hitchens was more focused on the present and the future, the pains and the moments to come.</p>',
        '2014-01-12',
        '2014-01-16'
    );

-- Discours sur les sciences et les arts

insert into
    book(id, name, publisher)
values
    (
        2,
        'Discours_sur_les_sciences_et_les_arts',
        'Garnier-Flammarion'
    );

insert into
    book_authors(book_id, authors_string)
values
    (
        2,
        'Jean-Jacques Rousseau'
    );

insert into
    book_years(book_id, years_string)
values
    (
        2,
        '1971'
    );

insert into
    book_years(book_id, years_string)
values
    (
        2,
        '(1750&nbsp;&amp;&nbsp;1755)'
    );

insert into
    title(id, book_id, title, link)
values
    (
        2,
        2,
        'Discours sur les sciences et les arts',
        'http://athena.unige.ch/athena/rousseau/rousseau_discours_sciences_arts.html'
    );

insert into
    title(id, book_id, title, link)
values
    (
        3,
        2,
        'Discours sur l''origine et les fondements de l''in&eacute;galit&eacute; parmis les hommes',
        'http://athena.unige.ch/athena/rousseau/rousseau_discours_inegalite.html'
    );

insert into
    title(id, book_id, title, link)
values
    (
        4,
        2,
        '<i>Discourse on the Arts and Sciences</i>',
        'https://en.wikipedia.org/wiki/Discourse_on_the_Arts_and_Sciences'
    );

insert into
    title(id, book_id, title, link)
values
    (
        5,
        2,
        '<i>Discourse on the Origin and Basis of Inequality Among Men</i>',
        'http://www.constitution.org/jjr/ineq.htm'
    );

insert into
    review(id, book_id, reviewer_id, body, start)
values
    (
        2,
        2,
        1,
        '<p>I read this back in high school.  Giving it a refresher.</p><p><i>More to come.</i></p>',
        '2016-05-24'
    );
