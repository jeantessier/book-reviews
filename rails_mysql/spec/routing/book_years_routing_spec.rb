require "rails_helper"

RSpec.describe BookYearsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/books/2/years").to route_to("book_years#index", :book_id => "2")
    end


    it "routes to #show" do
      expect(:get => "/books/2/years/1").to route_to("book_years#show", :book_id => "2", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/books/2/years").to route_to("book_years#create", :book_id => "2")
    end

    it "routes to #update via PUT" do
      expect(:put => "/books/2/years/1").to route_to("book_years#update", :book_id => "2", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/books/2/years/1").to route_to("book_years#update", :book_id => "2", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/books/2/years/1").to route_to("book_years#destroy", :book_id => "2", :id => "1")
    end

  end
end
