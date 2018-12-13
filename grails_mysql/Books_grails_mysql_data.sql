--
-- Roles
--

insert into
    role(id, authority)
values
    (
        1,
        'ROLE_USER'
    ),
    (
        2,
        'ROLE_ADMIN'
    );

--
-- Users
--

-- Jean

insert into
    user(id, name, email, password, date_created, last_updated)
values
    (
        1,
        'Jean Tessier',
        'jean@jeantessier.com',
        '0123456789abcdef0123456789abcdef',
        now(),
        now()
    );

insert into
    user_role(user_id, role_id)
values
    (
        1,
        1
    ),
    (
        1,
        2
    );
