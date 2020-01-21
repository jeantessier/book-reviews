FactoryBot.define do
  factory :random_user, class: User do
    email { Faker::Internet.unique.email }
    encrpted_password { Faker::Crypto.sha256 }
    name { Faker::Name.name }
  end

  factory :random_book, class: Book do
    name { Faker::Book.unique.title.gsub(' ', '_') }
    publisher { Faker::Book.publisher }
  end
end
