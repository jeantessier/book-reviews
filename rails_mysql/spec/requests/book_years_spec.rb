require 'rails_helper'

RSpec.describe "BookYears" do
  let(:book) { Book.create! name: "book_#{rand 1_000...10_000}" }

  describe "GET /books/1/years" do
    it "works! (now write some real specs)" do
      get "/books/#{book.id}/years"
      expect(response).to have_http_status(200)
    end
  end
end
