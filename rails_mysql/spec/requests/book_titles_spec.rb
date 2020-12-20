require 'rails_helper'

RSpec.describe "BookTitles" do
  let(:book) { FactoryBot.create :book }

  describe "GET /books/1/titles" do
    it "works! (now write some real specs)" do
      get "/books/#{book.id}/titles"
      expect(response).to have_http_status(200)
    end
  end
end
