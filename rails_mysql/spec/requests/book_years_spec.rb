require 'rails_helper'

RSpec.describe "BookYears", type: :request do
  describe "GET /book_years" do
    it "works! (now write some real specs)" do
      get book_years_path
      expect(response).to have_http_status(200)
    end
  end
end
