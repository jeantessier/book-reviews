# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#
# Users
#

jean = User.create name: 'Jean Tessier', email: 'jean@jeantessier.com', password: 'abcd1234'
simon = User.create name: 'Simon Tolkien', email: 'simon@tolkien.com', password: 'abcd1234'

#
# Books & Reviews
#

# Book: The Hobbit

book = Book.create name: 'The_Hobbit', publisher: 'Unwin & Allen'
book.titles.create title: 'The Hobbit', link: 'https://en.wikipedia.org/wiki/The_Hobbit', order: 1
book.titles.create title: 'Bilbo le Hobbit', link: 'https://fr.wikipedia.org/wiki/Le_Hobbit', order: 2
book.authors.create author: 'J.R.R. Tolkien'
book.years.create year: '1937'
book.reviews.create reviewer: jean, body: 'Awesome!', start: '2020-05-02', stop: '2020-05-20'
book.reviews.create reviewer: simon, body: 'Reminds me of when I was a kid.', start: '2020-05-01', stop: '2020-05-01'

# Book: The Lord of the Rings

book = Book.create name: 'The_Lord_of_the_Rings', publisher: 'Unwin & Allen'
book.titles.create title: 'The Lord of the Rings', link: 'https://en.wikipedia.org/wiki/The_Lord_of_the_Rings'
book.authors.create author: 'J.R.R. Tolkien'
book.years.create year: '1954', order: 1
book.years.create year: '1955', order: 2
book.reviews.create reviewer: jean, body: 'Awesome!', start: '2020-05-02', stop: '2020-05-20'

# Book: The Fellowship of the Ring

book = Book.create name: 'The_Fellowship_of_the_Ring', publisher: 'Unwin & Allen'
book.titles.create title: 'The Fellowship of the Ring', link: 'https://en.wikipedia.org/wiki/The_Fellowship_of_the_Ring'
book.authors.create author: 'J.R.R. Tolkien'
book.years.create year: '1954'
book.reviews.create reviewer: jean, body: 'The Council of Elrond is a little long.', start: '2020-05-02', stop: '2020-05-05'

# Book: The Two Towers

book = Book.create name: 'The_Two_Towers', publisher: 'Unwin & Allen'
book.titles.create title: 'The Two Towers', link: 'https://en.wikipedia.org/wiki/The_Two_Towers'
book.authors.create author: 'J.R.R. Tolkien'
book.years.create year: '1954'
book.reviews.create reviewer: jean, body: 'The Battle of Helm\'s Deep is a little long.', start: '2020-05-06', stop: '2020-05-10'

# Book: The Return of the King

book = Book.create name: 'The_Return_of_the_King', publisher: 'Unwin & Allen'
book.titles.create title: 'The Return of the King', link: 'https://en.wikipedia.org/wiki/The_Return_of_the_King'
book.authors.create author: 'J.R.R. Tolkien'
book.years.create year: '1955'
book.reviews.create reviewer: jean, body: 'The ending is a little long.', start: '2020-05-11', stop: '2020-05-20'

# Book: The Silmarillion

book = Book.create name: 'The_Silmarillion', publisher: 'Unwin & Allen'
book.titles.create title: 'The Silmarillion', link: 'https://en.wikipedia.org/wiki/The_Silmarillion'
book.authors.create author: 'Christopher Tolkien', order: 1
book.authors.create author: 'J.R.R. Tolkien', order: 2
book.years.create year: '1977'
book.reviews.create reviewer: jean, body: 'Epic!', start: '2020-05-21', stop: '2020-05-30'
book.reviews.create reviewer: simon, body: 'Bacon!', start: '2019-12-11', stop: '2019-12-20'
