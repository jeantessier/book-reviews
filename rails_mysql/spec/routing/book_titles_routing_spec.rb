require "rails_helper"

RSpec.describe BookTitlesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/book_titles").to route_to("book_titles#index")
    end


    it "routes to #show" do
      expect(:get => "/book_titles/1").to route_to("book_titles#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/book_titles").to route_to("book_titles#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/book_titles/1").to route_to("book_titles#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/book_titles/1").to route_to("book_titles#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/book_titles/1").to route_to("book_titles#destroy", :id => "1")
    end

  end
end
