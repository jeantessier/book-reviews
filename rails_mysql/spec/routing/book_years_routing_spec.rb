require "rails_helper"

RSpec.describe BookYearsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/book_years").to route_to("book_years#index")
    end


    it "routes to #show" do
      expect(:get => "/book_years/1").to route_to("book_years#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/book_years").to route_to("book_years#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/book_years/1").to route_to("book_years#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/book_years/1").to route_to("book_years#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/book_years/1").to route_to("book_years#destroy", :id => "1")
    end

  end
end
