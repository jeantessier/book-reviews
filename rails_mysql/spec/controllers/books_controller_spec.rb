require 'rails_helper'

RSpec.describe BooksController do
  let!(:book) { FactoryBot.create :book_with_title_links }

  let(:book_name) { Faker::Book.unique.title.gsub(' ', '_') }

  # This should return the minimal set of attributes required to create a valid
  # Book. As you add validations to Book, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
        name: book_name
    }
  end

  let(:invalid_attributes) do
    {
        foo: "bar"
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BooksController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let!(:user) { FactoryBot.create :user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      # binding.pry
      get :show, params: {id: book.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context  "not authenticated" do
      it "returns an error" do
        post :create, params: {book: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated" do
      before { sign_in user }

      context "with valid params" do
        it "creates a new Book" do
          expect do
            post :create, params: {book: valid_attributes}, session: valid_session
          end.to change(Book, :count).by(1)
        end

        it "renders a JSON response with the new book" do
          post :create, params: {book: valid_attributes}, session: valid_session
          expect(response).to have_http_status(:created)
          expect(response.media_type).to eq('application/json')
          expect(response.location).to eq(book_url(Book.last))
        end
      end

      context "with invalid params" do
        it "renders a JSON response with errors for the new book" do
          post :create, params: {book: invalid_attributes}, session: valid_session
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.media_type).to eq('application/json')
        end
      end
    end
  end

  describe "PUT #update" do
    context  "not authenticated" do
      it "returns an error" do
        put :update, params: {id: book.to_param, book: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated" do
      before { sign_in user }

      context "with valid params" do
        let(:expected_publisher) { Faker::Book.publisher }
        let(:new_attributes) do
          {
              publisher: expected_publisher
          }
        end

        it "updates the requested book" do
          put :update, params: {id: book.to_param, book: new_attributes}, session: valid_session
          book.reload
          expect(book.publisher).to eq(expected_publisher)
        end

        it "renders a JSON response with the book" do
          put :update, params: {id: book.to_param, book: new_attributes}, session: valid_session
          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq('application/json')
        end
      end

      context "with invalid params" do
        let(:other_book) { FactoryBot.create :book }

        it "renders a JSON response with errors for the book" do
          put :update, params: {id: book.to_param, book: {name: other_book.name}}, session: valid_session
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.media_type).to eq('application/json')
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "not authenticated" do
      it "returns an error" do
        delete :destroy, params: {id: book.to_param}, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not destroy the requested book" do
        expect do
          delete :destroy, params: {id: book.to_param}, session: valid_session
        end.not_to change(Book, :count)
      end
    end

    context "authenticated" do
      before { sign_in user }

      it "destroys the requested book" do
        expect do
          delete :destroy, params: {id: book.to_param}, session: valid_session
        end.to change(Book, :count).by(-1)
      end
    end
  end

end
