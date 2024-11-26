require 'rails_helper'

RSpec.describe ReviewsController do
  let(:book) { FactoryBot.create :book }
  let!(:user) { FactoryBot.create :user }
  let!(:review) { FactoryBot.create :review, reviewer: user, book: }

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
        reviewer_id: -1,
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ReviewsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: review.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "not authenticated"  do
      it "returns an error" do
        post :create, params: { review: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated" do
      before { sign_in user }

      context "with valid params" do
        it "creates a new Review" do
          expect do
            post :create, params: { review: valid_attributes }, session: valid_session
          end.to change(Review, :count).by(1)
        end

        it "renders a JSON response with the new review" do
          post :create, params: { review: valid_attributes }, session: valid_session
          expect(response).to have_http_status(:created)
          expect(response.media_type).to eq('application/json')
          expect(response.location).to eq(review_url(Review.last))
        end
      end

      context "with invalid params" do
        it "renders a JSON response with errors for the new review" do
          post :create, params: { review: invalid_attributes }, session: valid_session
          expect(response).to be_unprocessable
          expect(response.media_type).to eq('application/json')
        end
      end
    end
  end

  describe "PUT #update" do
    context "not authenticated"  do
      it "returns an error" do
        put :update, params: { id: review.to_param, review: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated" do
      before { sign_in user }

      context "with valid params" do
        let(:new_start) { Date.today }
        let(:new_attributes) do
          {
              start: new_start,
          }
        end

        it "updates the requested review" do
          put :update, params: { id: review.to_param, review: new_attributes }, session: valid_session
          review.reload
          expect(review.start).to eq(new_start)
        end

        it "renders a JSON response with the review" do
          put :update, params: { id: review.to_param, review: valid_attributes }, session: valid_session
          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq('application/json')
        end
      end

      context "with invalid params" do
        it "renders a JSON response with errors for the review" do
          put :update, params: { id: review.to_param, review: invalid_attributes }, session: valid_session
          expect(response).to be_unprocessable
          expect(response.media_type).to eq('application/json')
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "not authenticated"  do
      it "returns an error" do
        put :update, params: { id: review.to_param, review: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not destroy the requested review" do
        expect do
          delete :destroy, params: { id: review.to_param }, session: valid_session
        end.not_to change(Review, :count)
      end
    end

    context "authenticated" do
      before { sign_in user }

      it "destroys the requested review" do
        expect do
          delete :destroy, params: { id: review.to_param }, session: valid_session
        end.to change(Review, :count).by(-1)
      end
    end
  end
end
