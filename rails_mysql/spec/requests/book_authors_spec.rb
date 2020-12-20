require 'rails_helper'

RSpec.describe "BookAuthors" do
  let(:book) { FactoryBot.create :book }

  describe "GET /books/1/authors" do
    it "works! (now write some real specs)" do
      get "/books/#{book.id}/authors"
      expect(response).to have_http_status(200)
    end
  end
end
