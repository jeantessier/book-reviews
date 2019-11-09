require 'rails_helper'

RSpec.describe BookAuthor, type: :model do
  let(:book) { Book.create! name: "book_#{rand 1_000...10_000}" }
  let(:name) { "name #{rand 1_000...10_000}" }
  let(:order) { rand 0...10 }

  context "create" do
    it "should save with a book" do
      expect { BookAuthor.create! book: book, name: name, order: order }.to_not raise_error
    end

    it "should not save without a book" do
      expect { BookAuthor.create! name: name, order: order }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save without a name" do
      expect { BookAuthor.create! book: book, order: order }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context ".order" do
      it "should save without an order" do
        expect { BookAuthor.create! book: book, name: name }.to_not raise_error
      end

      it "should save without an order and get the default value" do
        book_author = BookAuthor.create! book: book, name: name
        expect(book_author.order).to eq(0)
      end

      it "should not save with an invalid order" do
        expect { BookAuthor.create! book: book, name: name, order: -1 }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
