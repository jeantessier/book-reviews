require 'rails_helper'

RSpec.describe BookYear, type: :model do
  let(:book) { Book.create! name: "book_#{rand 1_000...10_000}" }
  let(:year) { "year #{rand 1_000...10_000}" }
  let(:order) { rand 0...10 }

  context "create" do
    it "should save with a book" do
      expect { BookYear.create! book: book, year: year, order: order }.to_not raise_error
    end

    it "should not save without a book" do
      expect { BookYear.create! year: year, order: order }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save without a year" do
      expect { BookYear.create! book: book, order: order }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context ".order" do
      it "should save without an order" do
        expect { BookYear.create! book: book, year: year }.to_not raise_error
      end

      it "should save without an order and get the default value" do
        book_author = BookYear.create! book: book, year: year
        expect(book_author.order).to eq(0)
      end

      it "should not save with an invalid order" do
        expect { BookYear.create! book: book, year: year, order: -1 }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end