require "rails_helper"

RSpec.describe BookTitlesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/books/2/titles").to route_to("book_titles#index", :book_id => "2")
    end


    it "routes to #show" do
      expect(:get => "/books/2/titles/1").to route_to("book_titles#show", :book_id => "2", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/books/2/titles").to route_to("book_titles#create", :book_id => "2")
    end

    it "routes to #update via PUT" do
      expect(:put => "/books/2/titles/1").to route_to("book_titles#update", :book_id => "2", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/books/2/titles/1").to route_to("book_titles#update", :book_id => "2", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/books/2/titles/1").to route_to("book_titles#destroy", :book_id => "2", :id => "1")
    end

  end
end
