drop database if exists grails_mysql_book_reviews;
create database grails_mysql_book_reviews;

use grails_mysql_book_reviews;

--
-- Schema
--

create table book (
    id bigint(20) not null auto_increment,
    version bigint(20) not null default 0,
    name varchar(512) not null,
    publisher varchar(1024) not null,
    date_created datetime not null,
    last_updated datetime not null,
    primary key (id)
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
    username varchar(128) not null,
    password varchar(128) not null,
    enabled bit(1) not null default 1,
    account_expired bit(1) not null default 0,
    account_locked bit(1) not null default 0,
    password_expired bit(1) not null default 0,
    date_created datetime not null,
    last_updated datetime not null,
    primary key (id),
    unique key (username)
);

create table role (
    id bigint(20) not null auto_increment,
    version bigint(20) not null default 0,
    authority varchar(32) not null,
    primary key (id),
    unique key (authority)
);

create table user_role (
    user_id bigint(20) not null,
    role_id bigint(20) not null,
    primary key (user_id, role_id),
    key idx_user_id (user_id),
    constraint fk_user_role_user foreign key (user_id) references user(id),
    key idx_role_id (role_id),
    constraint fk_user_role_role foreign key (role_id) references role(id)
);

create table review (
    id bigint(20) not null auto_increment,
    version bigint(20) not null default 0,
    book_id bigint(20) not null,
    reviewer_id bigint(20) not null,
    body longtext not null,
    start datetime,
    stop datetime,
    date_created datetime not null,
    last_updated datetime not null,
    primary key (id),
    key idx_book_id (book_id),
    constraint fk_review_book foreign key (book_id) references book(id),
    key idx_reviewer_id (reviewer_id),
    constraint fk_review_user foreign key (reviewer_id) references user(id)
);
