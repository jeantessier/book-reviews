require 'rails_helper'

RSpec.describe Review do
  let(:reviewer) { FactoryBot.create :user }
  let(:book) { FactoryBot.create :book }
  let(:body) { Faker::Markdown.random }
  let(:start) { Faker::Date.backward }
  let(:stop) { Faker::Date.between from: start, to: Date.today }

  context "create" do
    it "should save with a reviewer and a book" do
      expect { Review.create! reviewer: reviewer, book: book, body: body, start: start, stop: stop }.to_not raise_error
    end

    it "should save without a start date" do
      expect { Review.create! reviewer: reviewer, book: book, body: body, stop: stop }.to_not raise_error
    end

    it "should save without a stop date" do
      expect { Review.create! reviewer: reviewer, book: book, body: body, start: start }.to_not raise_error
    end

    it "should not save without a body" do
      expect { Review.create! reviewer: reviewer, book: book, start: start, stop: stop }.to raise_error(ActiveRecord::RecordInvalid)
    end

    xit "should not save without a book" do
      expect { Review.create! reviewer: reviewer, body: body, start: start, stop: stop }.to raise_error(ActiveRecord::RecordInvalid)
    end

    xit "should not save without a reviewer" do
      expect { Review.create! book: book, body: body, start: start, stop: stop }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
