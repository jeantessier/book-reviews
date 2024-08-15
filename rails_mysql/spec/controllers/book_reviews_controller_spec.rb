require 'rails_helper'

RSpec.describe BookReviewsController do
  let(:book) { FactoryBot.create :book }
  let!(:review) { FactoryBot.create :review, book: book }
  let(:another_review) { FactoryBot.create :review }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { book_id: book.id }
      expect(response).to be_successful
    end

    it "includes the book's review" do
      get :index, params: { book_id: book.id }
      expect(JSON.parse(response.body)).to match [
        a_hash_including("id" => review.id, "book_id" => book.id),
      ]
    end

    it "does not include another book's review" do
      get :index, params: { book_id: book.id }
      expect(JSON.parse(response.body)).not_to match [
        a_hash_including("id" => another_review.id),
      ]
    end
  end

  describe "GET #show" do
    it "redirects to the ReviewsController" do
      get :show, params: { book_id: book.id, id: review.id }
      expect(response).to redirect_to(controller: "reviews", action: "show", id: review.id)
    end

    it "does not redirect to another book's review" do
      expect do
        get :show, params: { book_id: book.id, id: another_review.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
