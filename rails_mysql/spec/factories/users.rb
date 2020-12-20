FactoryBot.define do
  factory :user, aliases: [:reviewer] do
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
    name { Faker::Name.name }
  end
end
