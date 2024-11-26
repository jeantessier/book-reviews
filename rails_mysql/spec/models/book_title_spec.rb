require 'rails_helper'

RSpec.describe BookTitle do
  let(:book) { FactoryBot.create :book }
  let(:title) { Faker::Book.title }
  let(:link) { Faker::Internet.url }
  let(:order) { rand 1..10 }

  context "create" do
    it "should save with a book" do
      expect { BookTitle.create! book:, title:, link:, order: }.to_not raise_error
    end

    it "should save without a link" do
      expect { BookTitle.create! book:, title:, order: }.to_not raise_error
    end

    xit "should not save without a book" do
      expect { BookTitle.create! title:, link:, order: }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save without a year" do
      expect { BookTitle.create! book:, order: }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context ".order" do
      it "should save without an order" do
        expect { BookTitle.create! book:, title:, link: }.to_not raise_error
      end

      it "should save without an order and get the default value" do
        book_author = BookTitle.create! book:, title:, link: link
        expect(book_author.order).to eq(0)
      end

      it "should not save with an invalid order" do
        expect { BookTitle.create! book:, title:, link:, order: -1 }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context "sorting" do
    let(:book_title) { FactoryBot.build :book_title, book:, order: }

    it "should come after another BookTitle with lower order" do
      other = FactoryBot.build :book_title, book:, order: order - 1
      expect(book_title <=> other).to eq(1)
    end

    it "should come the same another BookTitle with the same order" do
      other = FactoryBot.build :book_title, book:, order: order
      expect(book_title <=> other).to eq(0)
    end

    it "should come before another BookTitle with higher order" do
      other = FactoryBot.build :book_title, book:, order: order + 1
      expect(book_title <=> other).to eq(-1)
    end
  end
end
