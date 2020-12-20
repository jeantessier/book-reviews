require 'rails_helper'

RSpec.describe Book do
  let(:expected_name) { Faker::Book.unique.title.gsub(' ', '_') }

  context ".name" do
    subject { Book.new(name: expected_name) }

    it "should have a name" do
      expect(subject.name).to eq(expected_name)
    end

    it "should not save without a name" do
      book = Book.new
      expect { book.save! }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  context ".publisher" do
    let(:expected_publisher) { Faker::Book.publisher }

    subject { Book.new(name: expected_name, publisher: expected_publisher) }

    it "can have a publisher" do
      expect(subject.publisher).to eq(expected_publisher)
    end

    it "can save without a publisher" do
      book = Book.new(name: expected_name)
      expect { book.save! }.to_not raise_error
    end
  end
end
