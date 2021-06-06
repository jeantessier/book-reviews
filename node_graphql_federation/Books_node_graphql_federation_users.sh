#
# Users
#

# User: Administrator
echo Adding "Administrator" ...

jean_id=$(addUser "Administrator" "admin@bookreviews.com" "abcd1234" '"ROLE_ADMIN", "ROLE_USER"')

echo '    ' User $jean_id

# User: Jean Tessier
echo Adding "Jean Tesssier" ...

jean_id=$(addUser "Jean Tessier" "jean@jeantessier.com" "abcd1234" '"ROLE_USER"')

echo '    ' User $jean_id
