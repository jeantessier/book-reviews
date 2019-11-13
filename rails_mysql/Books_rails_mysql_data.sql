--
-- Users
--

-- Jean
select 'Creating user Jean ...' as '';

insert into
    users(name, email, created_at, updated_at)
values
    (
        'Jean Tessier',
        'jean@jeantessier.com',
        now(),
        now()
    );

set @user_id = last_insert_id();
