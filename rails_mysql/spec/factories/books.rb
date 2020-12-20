FactoryBot.define do
  factory :book do
    transient do
      author_count { rand 1..3 }
      year_count { rand 1..3 }
      title_count { rand 1..3 }
    end

    name { Faker::Book.unique.title.gsub(' ', '_') }
    titles { Array.new(title_count) { association(:book_title) } }
    authors { Array.new(author_count) { association(:book_author) } }
    years { Array.new(year_count) { association(:book_year) } }
    publisher { Faker::Book.publisher }

    factory :book_with_title_links do
      titles { Array.new(title_count) { association(:book_title_with_link) } }
    end
  end

  factory :book_author do
    author { Faker::Book.author }
  end

  factory :book_year do
    year { Faker::Date.backward(days: 100 * 365).year.to_s }
  end

  factory :book_title do
    title { Faker::Book.title }

    factory :book_title_with_link do
      link { Faker::Internet.url }
    end
  end
end
