FactoryBot.define do
  factory :review do
    book
    reviewer
    body { Faker::Markdown.random }

    factory :review_in_progress do
      start { Faker::Date.backward }

      factory :completed_review do
        stop { Faker::Date.between from: start, to: Date.today }
      end
    end
  end
end
