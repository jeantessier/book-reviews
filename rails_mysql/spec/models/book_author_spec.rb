require 'rails_helper'

RSpec.describe BookAuthor, type: :model do
  let(:book) { Book.create! name: "book_#{rand 1_000...10_000}" }

  context "create" do
    it "should save with a book" do
      expect { BookAuthor.create! book: book, order: 1 }.to_not raise_error
    end

    it "should not save without a book" do
      expect { BookAuthor.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save without an order" do
      expect { BookAuthor.create! book: book }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save witn an invalid order" do
      expect { BookAuthor.create! book: book, order: -1 }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
