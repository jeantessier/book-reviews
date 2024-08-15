require 'rails_helper'

RSpec.describe UserReviewsController do
  let(:user) { FactoryBot.create :user }
  let!(:review) { FactoryBot.create :review, reviewer: user }
  let(:another_review) { FactoryBot.create :review }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { user_id: user.id }
      expect(response).to be_successful
    end

    it "includes the user's review" do
      get :index, params: { user_id: user.id }
      expect(JSON.parse(response.body)).to match [
        a_hash_including("id" => review.id, "reviewer_id" => user.id),
      ]
    end

    it "does not include another user's review" do
      get :index, params: { user_id: user.id }
      expect(JSON.parse(response.body)).not_to match [
        a_hash_including("id" => another_review.id),
      ]
    end
  end

  describe "GET #show" do
    it "redirects to the ReviewsController" do
      get :show, params: { user_id: user.id, id: review.id }
      expect(response).to redirect_to(controller: "reviews", action: "show", id: review.id)
    end

    it "does not redirect to another user's review" do
      expect do
        get :show, params: { user_id: user.id, id: another_review.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
