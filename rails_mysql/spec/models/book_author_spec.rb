require 'rails_helper'

RSpec.describe BookAuthor, type: :model do
  let(:book) { Book.create! name: "book_#{rand 1_000...10_000}" }
  let(:author) { "author #{rand 1_000...10_000}" }
  let(:order) { rand 1..10 }

  context "create" do
    it "should save with a book" do
      expect { BookAuthor.create! book: book, author: author, order: order }.to_not raise_error
    end

    xit "should not save without a book" do
      expect { BookAuthor.create! author: author, order: order }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save without an author" do
      expect { BookAuthor.create! book: book, order: order }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context ".order" do
      it "should save without an order" do
        expect { BookAuthor.create! book: book, author: author }.to_not raise_error
      end

      it "should save without an order and get the default value" do
        book_author = BookAuthor.create! book: book, author: author
        expect(book_author.order).to eq(0)
      end

      it "should not save with an invalid order" do
        expect { BookAuthor.create! book: book, author: author, order: -1 }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context "sorting" do
    let(:book_author) { BookAuthor.create! book: book, author: author, order: order }
    let(:other_author) { "other name #{rand 1_000...10_000}" }

    it "should come after another BookAuthor with lower order" do
      other = BookAuthor.create! book: book, author: other_author, order: order - 1
      expect(book_author <=> other).to eq(1)
    end

    it "should come the same another BookAuthor with the same order" do
      other = BookAuthor.create! book: book, author: other_author, order: order
      expect(book_author <=> other).to eq(0)
    end

    it "should come before another BookAuthor with higher order" do
      other = BookAuthor.create! book: book, author: other_author, order: order + 1
      expect(book_author <=> other).to eq(-1)
    end
  end
end
