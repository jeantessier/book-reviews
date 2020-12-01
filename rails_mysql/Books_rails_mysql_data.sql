--
-- Reviews
--

delete from reviews;

--
-- Users
--

-- delete from users;

-- Jean
-- select 'Creating user Jean ...' as '';

-- insert into
--     users(name, email, created_at, updated_at)
-- values
--     (
--         'Jean Tessier',
--         'jean@jeantessier.com',
--         now(),
--         now()
--     );
--
-- set @user_id = last_insert_id();

set @user_id = (select id from users where email = 'jean@jeantessier.com');

--
-- Books
--

delete from book_authors;
delete from book_titles;
delete from book_years;
delete from books;
