require 'rails_helper'

RSpec.describe "BookTitles", type: :request do
  describe "GET /book_titles" do
    it "works! (now write some real specs)" do
      get book_titles_path
      expect(response).to have_http_status(200)
    end
  end
end
