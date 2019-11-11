require 'rails_helper'

RSpec.describe BookTitle, type: :model do
  let(:book) { Book.create! name: "book_#{rand 1_000...10_000}" }
  let(:title) { "title #{rand 1_000...10_000}" }
  let(:link) { "link #{rand 1_000...10_000}" }
  let(:order) { rand 0...10 }

  context "create" do
    it "should save with a book" do
      expect { BookTitle.create! book: book, title: title, link: link, order: order }.to_not raise_error
    end

    it "should save without a link" do
      expect { BookTitle.create! book: book, title: title, order: order }.to_not raise_error
    end

    it "should not save without a book" do
      expect { BookTitle.create! title: title, link: link, order: order }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save without a year" do
      expect { BookTitle.create! book: book, order: order }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context ".order" do
      it "should save without an order" do
        expect { BookTitle.create! book: book, title: title, link: link }.to_not raise_error
      end

      it "should save without an order and get the default value" do
        book_author = BookTitle.create! book: book, title: title, link: link
        expect(book_author.order).to eq(0)
      end

      it "should not save with an invalid order" do
        expect { BookTitle.create! book: book, title: title, link: link, order: -1 }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
