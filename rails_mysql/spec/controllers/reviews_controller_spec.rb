require 'rails_helper'

RSpec.describe ReviewsController do
  let(:book) { FactoryBot.create :book }
  let!(:user) { FactoryBot.create :user }
  let!(:review) { FactoryBot.create :review, reviewer: user, book: book }

  # This should return the minimal set of attributes required to create a valid
  # Review. As you add validations to Review, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
        reviewer_id: user.id,
        book_id: book.id,
        body: Faker::Markdown.random,
    }
  end

  let(:invalid_attributes) do
    {
        reviewer_id: -1
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ReviewsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:jwt_token) { Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:auth_header) { { 'Authorization': "Bearer #{jwt_token}" } }

  # I think this version of RSpec does not handle headers passed to #get or #post
  # So, we cannot use:
  #     post :create, params: {book: valid_attributes}, session: valid_session, headers: auth_header
  # We have to inject a valid token into the controller directly.  Yuck!
  before(:example) do
    def @controller.token_from_request_headers
      Knock::AuthToken.new(payload: { sub: User.all.first.id }).token
    end
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: {id: review.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Review" do
        expect do
          post :create, params: {review: valid_attributes}, session: valid_session
        end.to change(Review, :count).by(1)
      end

      it "renders a JSON response with the new review" do
        post :create, params: {review: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.media_type).to eq('application/json')
        expect(response.location).to eq(review_url(Review.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new review" do
        post :create, params: {review: invalid_attributes}, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.media_type).to eq('application/json')
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_start) { Date.today }
      let(:new_attributes) do
        {
            start: new_start,
        }
      end

      it "updates the requested review" do
        put :update, params: {id: review.to_param, review: new_attributes}, session: valid_session
        review.reload
        expect(review.start).to eq(new_start)
      end

      it "renders a JSON response with the review" do
        put :update, params: {id: review.to_param, review: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the review" do
        put :update, params: {id: review.to_param, review: invalid_attributes}, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.media_type).to eq('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested review" do
      expect do
        delete :destroy, params: {id: review.to_param}, session: valid_session
      end.to change(Review, :count).by(-1)
    end
  end
end
