require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe BookYearsController, type: :controller do
  let(:book) { Book.create! name: "book_#{rand 1_000...10_000}" }

  # This should return the minimal set of attributes required to create a valid
  # BookYear. As you add validations to BookYear, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
        book_id: book.id,
        year: "year #{rand 1_000...10_000}",
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
  # BookYearsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let!(:user) do
    user = User.create email: "email-#{rand 1_000...10_000}@test.com"
    user.password = "password #{rand 1_000...10_000}"
    user.save!
    return user
  end

  let(:jwt_token) { Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:auth_header) { { 'Authorization': "Bearer #{jwt_token}" } }

  # I think this version of RSpec does not handle headers passed to #get or #post
  # So, we cannot use:
  #     post :create, params: {book: valid_attributes}, session: valid_session, headers: auth_header
  # We have to inject a valid token into the controller directly.  Yuck!
  before(:example) do
    def @controller.token_from_request_headers
      Knock::AuthToken.new(payload: { sub: 1 }).token
    end
  end

  describe "GET #index" do
    it "returns a success response" do
      book_year = BookYear.create! valid_attributes
      get :index, params: {book_id: book.id}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      book_year = BookYear.create! valid_attributes
      get :show, params: {book_id: book.id, id: book_year.to_param}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new BookYear" do
        expect do
          post :create, params: {book_id: book.id, book_year: valid_attributes}, session: valid_session
        end.to change(BookYear, :count).by(1)
      end

      it "renders a JSON response with the new book_year" do

        post :create, params: {book_id: book.id, book_year: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new book_year" do

        post :create, params: {book_id: book.id, book_year: invalid_attributes}, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_order) { rand(1_000...10_000) }
      let(:new_attributes) do
        {
            order: new_order
        }
      end

      it "updates the requested book_year" do
        book_year = BookYear.create! valid_attributes
        put :update, params: {book_id: book.id, id: book_year.to_param, book_year: new_attributes}, session: valid_session
        book_year.reload
        expect(book_year.order).to eq(new_order)
      end

      it "renders a JSON response with the book_year" do
        book_year = BookYear.create! valid_attributes

        put :update, params: {book_id: book.id, id: book_year.to_param, book_year: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the book_year" do
        book_year = BookYear.create! valid_attributes

        put :update, params: {book_id: book.id, id: book_year.to_param, book_year: invalid_attributes}, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested book_year" do
      book_year = BookYear.create! valid_attributes
      expect do
        delete :destroy, params: {book_id: book.id, id: book_year.to_param}, session: valid_session
      end.to change(BookYear, :count).by(-1)
    end
  end

end