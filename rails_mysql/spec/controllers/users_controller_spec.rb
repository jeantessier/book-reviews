require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user) do
    user = User.create email: "email-#{rand 1_000...10_000}@test.com"
    user.password = "password #{rand 1_000...10_000}"
    user.save!
    return user
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: {id: user.to_param}
      expect(response).to be_success
    end
  end

end
