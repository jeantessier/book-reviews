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

book = Book.create name: 'The_Hobbbit', publisher: 'Unwin & Allen'
BookTitle.create book: book, title: 'The Hobbit', link: 'https://en.wikipedia.org/wiki/The_Hobbit'
BookTitle.create book: book, title: 'Bilbo le Hobbit', link: 'https://fr.wikipedia.org/wiki/Le_Hobbit'
BookAuthor.create book: book, author: 'J.R.R. Tolkien'
BookYear.create book: book, year: '1937'
Review.create book: book, reviewer: jean, body: 'Awesome!', start: '2020-05-02', stop: '2020-05-20'
Review.create book: book, reviewer: simon, body: 'Reminds me of when I was a kid.', start: '2020-05-01', stop: '2020-05-01'

# Book: The Lord of the Rings

book = Book.create name: 'The_Lord_of_the_Rings', publisher: 'Unwin & Allen'
BookTitle.create book: book, title: 'The Lord of the Rings', link: 'https://en.wikipedia.org/wiki/The_Lord_of_the_Rings'
BookAuthor.create book: book, author: 'J.R.R. Tolkien'
BookYear.create book: book, year: '1954'
BookYear.create book: book, year: '1955'
Review.create book: book, reviewer: jean, body: 'Awesome!', start: '2020-05-02', stop: '2020-05-20'

# Book: The Fellowship of the Ring

book = Book.create name: 'The_Fellowship_of_the_Ring', publisher: 'Unwin & Allen'
BookTitle.create book: book, title: 'The Fellowship of the Ring', link: 'https://en.wikipedia.org/wiki/The_Fellowship_of_the_Ring'
BookAuthor.create book: book, author: 'J.R.R. Tolkien'
BookYear.create book: book, year: '1954'
Review.create book: book, reviewer: jean, body: 'The Council of Elrond is a little long.', start: '2020-05-02', stop: '2020-05-05'

# Book: The Two Towers

book = Book.create name: 'The_Two_Towers', publisher: 'Unwin & Allen'
BookTitle.create book: book, title: 'The Two Towers', link: 'https://en.wikipedia.org/wiki/The_Two_Towers'
BookAuthor.create book: book, author: 'J.R.R. Tolkien'
BookYear.create book: book, year: '1954'
Review.create book: book, reviewer: jean, body: 'The Battle of Helm\'s Deep is a little long.', start: '2020-05-06', stop: '2020-05-10'

# Book: The Return of the King

book = Book.create name: 'The_Return_of_the_King', publisher: 'Unwin & Allen'
BookTitle.create book: book, title: 'The Return of the King', link: 'https://en.wikipedia.org/wiki/The_Return_of_the_King'
BookAuthor.create book: book, author: 'J.R.R. Tolkien'
BookYear.create book: book, year: '1955'
Review.create book: book, reviewer: jean, body: 'The ending is a little long.', start: '2020-05-11', stop: '2020-05-20'

# Book: The Silmarillion

book = Book.create name: 'The_Silmarillion', publisher: 'Unwin & Allen'
BookTitle.create book: book, title: 'The Silmarillion', link: 'https://en.wikipedia.org/wiki/The_Silmarillion'
BookAuthor.create book: book, author: 'Christopher Tolkien'
BookAuthor.create book: book, author: 'J.R.R. Tolkien'
BookYear.create book: book, year: '1977'
Review.create book: book, reviewer: jean, body: 'Epic!', start: '2020-05-21', stop: '2020-05-30'
Review.create book: book, reviewer: simon, body: 'Bacon!', start: '2019-12-11', stop: '2019-12-20'
