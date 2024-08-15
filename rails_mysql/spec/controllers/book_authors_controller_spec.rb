require 'rails_helper'

RSpec.describe BookAuthorsController do
  let(:book) { FactoryBot.create :book }
  let!(:book_author) { FactoryBot.create :book_author, book: book }

  # This should return the minimal set of attributes required to create a valid
  # BookAuthor. As you add validations to BookAuthor, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
        book_id: book.id,
        author: Faker::Book.author,
        order: 0
    }
  end

  let(:invalid_attributes) do
    {
        book_id: book.id,
        order: -1
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BookAuthorsController. Be sure to keep this updated too.
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

      let(:book) { FactoryBot.create :book, author_count: 0 }

      it "authors are in increasing order" do
        FactoryBot.create :book_author, book: book, order: last_order
        FactoryBot.create :book_author, book: book, order: middle_order
        FactoryBot.create :book_author, book: book, order: first_order
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
      get :show, params: { book_id: book.id, id: book_author.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "not authenticated"  do
      it "returns an error" do
        post :create, params: { book_id: book.id, book_author: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated" do
      before { sign_in user }

      context "with valid params" do
        it "creates a new BookAuthor" do
          expect do
            post :create, params: { book_id: book.id, book_author: valid_attributes }, session: valid_session
          end.to change(BookAuthor, :count).by(1)
        end

        it "renders a JSON response with the new book_author" do
          post :create, params: { book_id: book.id, book_author: valid_attributes }, session: valid_session
          expect(response).to have_http_status(:created)
          expect(response.media_type).to eq('application/json')
        end
      end

      context "with invalid params" do
        it "renders a JSON response with errors for the new book_author" do
          post :create, params: { book_id: book.id, book_author: invalid_attributes }, session: valid_session
          expect(response).to be_unprocessable
          expect(response.media_type).to eq('application/json')
        end
      end
    end
  end

  describe "PUT #update" do
    context "not authenticated"  do
      it "returns an error" do
        post :update, params: { book_id: book.id, id: book_author.to_param, book_author: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated" do
      before { sign_in user }

      context "with valid params" do
        let(:new_order) { rand(1_000...10_000) }
        let(:new_attributes) do
          {
              order: new_order
          }
        end

        it "updates the requested book_author" do
          put :update, params: { book_id: book.id, id: book_author.to_param, book_author: new_attributes }, session: valid_session
          book_author.reload
          expect(book_author.order).to eq(new_order)
        end

        it "renders a JSON response with the book_author" do
          put :update, params: { book_id: book.id, id: book_author.to_param, book_author: valid_attributes }, session: valid_session
          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq('application/json')
        end
      end

      context "with invalid params" do
        it "renders a JSON response with errors for the book_author" do
          put :update, params: { book_id: book.id, id: book_author.to_param, book_author: invalid_attributes }, session: valid_session
          expect(response).to be_unprocessable
          expect(response.media_type).to eq('application/json')
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "not authenticated"  do
      it "returns an error" do
        delete :destroy, params: { book_id: book.id, id: book_author.to_param }, session: valid_session
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not destroy the requested book_author" do
        expect do
          delete :destroy, params: { book_id: book.id, id: book_author.to_param }, session: valid_session
        end.not_to change(BookAuthor, :count)
      end
    end

    context "authenticated" do
      before { sign_in user }

      it "destroys the requested book_author" do
        expect do
          delete :destroy, params: { book_id: book.id, id: book_author.to_param }, session: valid_session
        end.to change(BookAuthor, :count).by(-1)
      end
    end
  end
end
