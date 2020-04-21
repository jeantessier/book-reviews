require 'rails_helper'

RSpec.describe "Books", type: :request do
  describe "GET /books" do
    let!(:books) { FactoryBot.create_list(:random_book, 3) }

    before { get books_path }

    it "returns 200 (Success)" do
      expect(response).to be_successful
    end

    it "has the correct number of books" do
      expect(JSON.parse(response.body).size).to eq(books.size)
    end

    it "includes all of the books" do
      expect(JSON.parse(response.body)).to match(books.collect {|book| a_hash_including('name' => book.name, 'publisher' => book.publisher)})
    end
  end
end
