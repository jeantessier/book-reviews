require 'rails_helper'

RSpec.describe BookAuthor do
  let(:book) { FactoryBot.create :book }
  let(:author) { Faker::Book.author }
  let(:order) { rand 1..10 }

  context "create" do
    it "should save with a book" do
      expect { BookAuthor.create! book:, author:, order: }.to_not raise_error
    end

    xit "should not save without a book" do
      expect { BookAuthor.create! author:, order: }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save without an author" do
      expect { BookAuthor.create! book:, order: }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context ".order" do
      it "should save without an order" do
        expect { BookAuthor.create! book:, author: }.to_not raise_error
      end

      it "should save without an order and get the default value" do
        book_author = BookAuthor.create! book:, author: author
        expect(book_author.order).to eq(0)
      end

      it "should not save with an invalid order" do
        expect { BookAuthor.create! book:, author:, order: -1 }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context "sorting" do
    let(:book_author) { FactoryBot.build :book_author, book:, order: }

    it "should come after another BookAuthor with lower order" do
      other = FactoryBot.build :book_author, book:, order: order - 1
      expect(book_author <=> other).to eq(1)
    end

    it "should come the same another BookAuthor with the same order" do
      other = FactoryBot.build :book_author, book:, order: order
      expect(book_author <=> other).to eq(0)
    end

    it "should come before another BookAuthor with higher order" do
      other = FactoryBot.build :book_author, book:, order: order + 1
      expect(book_author <=> other).to eq(-1)
    end
  end
end
