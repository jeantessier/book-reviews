# book-reviews

I am exploring various technology stacks for web-based apps for my own personal
education.

## Context

I am building an app to collect reviews of books.  The app will be multi-user
so I can experiment with authentication and authorization frameworks in each
technology stack.

## Requirements

1. Anonymous user can view a book and its reviews.
1. Anonymous user can search books and reviews by keyword.
1. User can register.
1. User can login.
1. User can write a review of a book.
1. User can edit their own reviews.
1. Admin user can edit anyone's reviews.
1. Admin user can enter a new book.
1. Admin user can edit a book's data.

## Variations

Various storage options:

* Relational database (MySQL)
* NoSQL (MongoDB, Redis)

Various stacks for middleware, returning both HTML and JSON:

* NodeJS
* Grails
* Micronaut
* Ruby on Rails
* Django
* Spring Boot and/or Ratpack and/or JHipster

Various frontend stacks:

* HTML (w/ jQuery)
* AngularJS
* React

## Model

### Book

* `name` (unique string, no spaces, underscores separate words)
* `titles` (an ordered list of links with HTML markup)
* `authors` (an ordered list of names with HTML markup)
* `publisher` (a string)
* `years` (an ordered list of year designations with HTML markup)

Books have a one-to-many relationship to reviews.

A simple example:

    {
        "name": "Mortality",
        "titles": [
            {
                "title": "Mortality",
                "link": "http://amzn.com/1455502758"
            }
        ],
        "authors": [
            "Christopher Hitchens"
        ],
        "publisher": "Twelve (Hachette)",
        "years": [
            "2012"
        ]
    }

A more complex sample:

    {
        "name": "Discours_sur_les_sciences_et_les_arts",
        "titles": [
            {
                "title": "Discours sur les sciences et les arts",
                "link": "http://athena.unige.ch/athena/rousseau/rousseau_discours_sciences_arts.html"
            },
            {
                "title": "Discours sur l'origine et les fondements de l'in&eacute;galit&eacute; parmis les hommes",
                "link": "http://athena.unige.ch/athena/rousseau/rousseau_discours_inegalite.html"
            },
            {
                "title": "<i>Discourse on the Arts and Sciences</i>",
                "link": "https://en.wikipedia.org/wiki/Discourse_on_the_Arts_and_Sciences"
            },
            {
                "title": "<i>Discourse on the Origin and Basis of Inequality Among Men</i>",
                "link": "http://www.constitution.org/jjr/ineq.htm"
            }
        ],
        "authors": [
            "Jean-Jacques Rousseau"
        ],
        "publisher": "Garnier-Flammarion",
        "years": [
            "1971",
            "(1750&nbsp;&amp;&nbsp;1755)"
        ],
    }

### User

The `User` entity is used to authenticate the app's user and to make sure they can edit the reviews they have created, but not the reviews of other users.

* `name`
* `email` (unique)
* `password` (encrypted)
* `salt` (for password encryption)

Users have a one-to-many relationship to reviews.

The `salt` is used in the encryption of the `password`, combined with an application-wide secret.

An example:

    {
        "name": "Jean Tessier",
        "email": "jean@jeantessier.com",
        "password": "0123456789abcdef9842ed9614143f40ca11e5c24da1d1a115087efc6dc2205ce46ee788737dfe06d02ad5d2c5ba67b1ef571dd00bd50136ba2ed5e9f6301e0f",
        "salt": "0123456789abcdef0123456789abcdef"
    }

### Review

* `body` (HTML markup)
* `start` (an optional date for when the reviewer started reading the book)
* `stop` (an optional date for when the reviewer finished reading the book)

Each review also has a relationship with a book and a user who is the reviewer.

An example with embedded markup for paragraphs and lists:

    {
        "body": "<p>Hitchens told his editor he would write about anything except sports.  So when he was diagnosed with cancer, he wrote about it.  And as he approached his own end, he kept on writing.  He takes us on an intimate ride along as he explores his attitude towards death.</p><p>Early on, when death is but a shadow on the distant horizon, Hitchens is more outward-facing.  He deals with religion and people wishing him well (and sometimes not).  As the book and his cancer progress, he sheds externalities and slowly gets more personal.</p><p>Breakdown by chapter:</p><ol><li>Diagnosis, dealing with the news, side effects of therapy.</li><li>People express their religious sentiments.  He'll have none of it.</li><li>The medical establishment tries everything to fight the disease.  More false hopes.</li><li>People's euphemisms to avoid talking about death.</li><li>Losing his voice strikes <i>really</i> close to home.  Voice and expression are at the core of existence.</li><li>How people choose to die.  How what almost kills him is <b>not</b> making him stronger.  Starts to yearn for the end.</li><li>Personal observations on pain and fear, in the face of torture ... or medical procedures.</li><li>Unfinished thoughts.  Fitting that at the end, even his mind comes apart.</li></ol><p>Hitchens mentions journalist John Diamond who also wrote a regular column about his experience with cancer, up to his death.  He mentions how his story \"lacked compactness toward the end...\"  He didn't fall into the same trap.  The book is concise and to the point, a quick read that goes straight to the point.</p><p>On 2014-01-26, I came upon this New York Times article where Dr. Paul Kalanithi recounts <a target=\"_blank\" href=\"http://nyti.ms/1eXxdlj\">when he was diagnosed with lung cancer</a>.  He talks about the patient-doctor relationship and how focusing too much on survival rates can make you miss the important things in life.  I can't help but wonder at the timing coincidence of seeing this article just as I finished reading Mortality.  Is it that lots of people are currently contemplating their own mortality these days?  Or is it me who is more sensitized to it because I just read this book?</p><p>On 2015-02-19, I came upon another New York Times article where <a target=\"_blank\" href=\"http://nyti.ms/17u5LNP\">Dr. Oliver Sacks talks about his cancer diagnosis</a>.  I find it interesting that at this point, he is looking back upon his life.  Hitchens was more focused on the present and the future, the pains and the moments to come.</p>",
        "start": "2014-01-12",
        "stop": "2014-01-16"
    }

An example where the reviewer is still in the middle of reading the book:

    {
        "body": "<p>I read this back in high school.  Giving it a refresher.</p><p><i>More to come.</i></p>",
        "start": "2016-05-24"
    }

Sample where the reviewer hasn't even read the book:

    {
        "body": "<p>I haven't read it, but I still have an opinion.</p>"
    }

## Data

See the [data/](data) folder for sample data.
