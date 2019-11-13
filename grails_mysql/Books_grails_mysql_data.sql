--
-- Roles
--

insert into
    role(authority)
values
    (
        'ROLE_USER'
    ),
    (
        'ROLE_ADMIN'
    );

--
-- Users
--

-- Jean
select 'Creating user Jean ...' as '';

insert into
    user(name, email, date_created, last_updated)
values
    (
        'Jean Tessier',
        'jean@jeantessier.com',
        now(),
        now()
    );

set @user_id = last_insert_id();

insert into
    user_role(user_id, role_id)
select
    @user_id as user_id,
    id as role_id
from
    role;
