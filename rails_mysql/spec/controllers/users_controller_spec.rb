require 'rails_helper'

RSpec.describe UsersController do
  let!(:user) { FactoryBot.create :user }

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: {id: user.to_param}
      expect(response).to be_successful
    end
  end

end
