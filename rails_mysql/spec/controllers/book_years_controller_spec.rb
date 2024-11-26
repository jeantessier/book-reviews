require 'rails_helper'

RSpec.describe BookYearsController do
  let(:book) { FactoryBot.create :book }
  let!(:book_year) { FactoryBot.create :book_year, book: }

  # This should return the minimal set of attributes required to create a valid
  # BookYear. As you add validations to BookYear, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
        book_id: book.id,
        year: Faker::Date.backward(days: 100 * 365).year.to_s,
        order: 0,
    }
  end

  let(:invalid_attributes) do
    {
        book_id: book.id,
        order: -1,
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BookYearsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let!(:user) { FactoryBot.create :user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { book_id: book.id }, session: valid_session
      expect(response).to be_successful
    end

    context "sort order" do
      let(:first_order) { rand 1...10 }
      let(:middle_order) { rand 10...100 }
      let(:last_order) { rand 100...1_000 }

      let(:book) { FactoryBot.create :book, year_count: 0 }

      it "years are in increasing order" do
        FactoryBot.create :book_year, book:, order: last_order
        FactoryBot.create :book_year, book:, order: middle_order
        FactoryBot.create :book_year, book:, order: first_order
        get :index, params: { book_id: book.id }, session: valid_session
        expect(JSON.parse(response.body)).to match [
            a_hash_including("order" => 0),
            a_hash_including("order" => first_order),
            a_hash_including("order" => middle_order),
            a_hash_including("order" => last_order),
        ]
      end
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { book_id: book.id, id: book_year.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "not authenticated"  do
      it "returns an error" do
        post :create, params: { book_id: book.id, book_year: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated" do
      before { sign_in user }

      context "with valid params" do
        it "creates a new BookYear" do
          expect do
            post :create, params: { book_id: book.id, book_year: valid_attributes }, session: valid_session
          end.to change(BookYear, :count).by(1)
        end

        it "renders a JSON response with the new book_year" do
          post :create, params: { book_id: book.id, book_year: valid_attributes }, session: valid_session
          expect(response).to have_http_status(:created)
          expect(response.media_type).to eq('application/json')
        end
      end

      context "with invalid params" do
        it "renders a JSON response with errors for the new book_year" do
          post :create, params: { book_id: book.id, book_year: invalid_attributes }, session: valid_session
          expect(response).to be_unprocessable
          expect(response.media_type).to eq('application/json')
        end
      end
    end
  end

  describe "PUT #update" do
    context "not authenticated"  do
      it "returns an error" do
        put :update, params: { book_id: book.id, id: book_year.to_param, book_year: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated" do
      before { sign_in user }

      context "with valid params" do
        let(:new_order) { rand(1_000...10_000) }
        let(:new_attributes) do
          {
              order: new_order,
          }
        end

        it "updates the requested book_year" do
          put :update, params: { book_id: book.id, id: book_year.to_param, book_year: new_attributes }, session: valid_session
          book_year.reload
          expect(book_year.order).to eq(new_order)
        end

        it "renders a JSON response with the book_year" do
          put :update, params: { book_id: book.id, id: book_year.to_param, book_year: valid_attributes }, session: valid_session
          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq('application/json')
        end
      end

      context "with invalid params" do
        it "renders a JSON response with errors for the book_year" do
          put :update, params: { book_id: book.id, id: book_year.to_param, book_year: invalid_attributes }, session: valid_session
          expect(response).to be_unprocessable
          expect(response.media_type).to eq('application/json')
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "not authenticated"  do
      it "returns an error" do
        delete :destroy, params: { book_id: book.id, id: book_year.to_param }, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not destroy the requested book_year" do
        expect do
          delete :destroy, params: { book_id: book.id, id: book_year.to_param }, session: valid_session
        end.not_to change(BookYear, :count)
      end
    end

    context "authenticated" do
      before { sign_in user }

      it "destroys the requested book_year" do
        expect do
          delete :destroy, params: { book_id: book.id, id: book_year.to_param }, session: valid_session
        end.to change(BookYear, :count).by(-1)
      end
    end
  end
end
