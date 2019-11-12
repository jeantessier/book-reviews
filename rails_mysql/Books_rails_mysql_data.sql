--
-- Users
--

-- Jean

insert into
    users(id, name, email, created_at, updated_at)
values
    (
        1,
        'Jean Tessier',
        'jean@jeantessier.com',
        now(),
        now()
    );
