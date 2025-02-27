require 'rails_helper'

RSpec.describe BookYear do
  let(:book) { FactoryBot.create :book }
  let(:year) { Faker::Date.backward(days: 100 * 365).year.to_s }
  let(:order) { rand 1..10 }

  context "create" do
    it "should save with a book" do
      expect { BookYear.create! book:, year:, order: }.to_not raise_error
    end

    xit "should not save without a book" do
      expect { BookYear.create! year:, order: }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save without a year" do
      expect { BookYear.create! book:, order: }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context ".order" do
      it "should save without an order" do
        expect { BookYear.create! book:, year: }.to_not raise_error
      end

      it "should save without an order and get the default value" do
        book_author = BookYear.create! book:, year: year
        expect(book_author.order).to eq(0)
      end

      it "should not save with an invalid order" do
        expect { BookYear.create! book:, year:, order: -1 }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context "sorting" do
    let(:book_year) { FactoryBot.build :book_year, book:, order: }

    it "should come after another BookYear with lower order" do
      other = FactoryBot.build :book_year, book:, order: order - 1
      expect(book_year <=> other).to eq(1)
    end

    it "should come the same another BookYear with the same order" do
      other = FactoryBot.build :book_year, book:, order: order
      expect(book_year <=> other).to eq(0)
    end

    it "should come before another BookYear with higher order" do
      other = FactoryBot.build :book_year, book:, order: order + 1
      expect(book_year <=> other).to eq(-1)
    end
  end
end
