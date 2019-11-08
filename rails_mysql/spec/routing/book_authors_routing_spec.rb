require "rails_helper"

RSpec.describe BookAuthorsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/books/2/authors").to route_to("book_authors#index", :book_id => "2")
    end


    it "routes to #show" do
      expect(:get => "/books/2/authors/1").to route_to("book_authors#show", :book_id => "2", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/books/2/authors").to route_to("book_authors#create", :book_id => "2")
    end

    it "routes to #update via PUT" do
      expect(:put => "/books/2/authors/1").to route_to("book_authors#update", :book_id => "2", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/books/2/authors/1").to route_to("book_authors#update", :book_id => "2", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/books/2/authors/1").to route_to("book_authors#destroy", :book_id => "2", :id => "1")
    end

  end
end
