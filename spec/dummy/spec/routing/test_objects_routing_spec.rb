require "spec_helper"

describe TestObjectsController do
  describe "routing" do

    it "routes to #index" do
      get("/test_objects").should route_to("test_objects#index")
    end

    it "routes to #new" do
      get("/test_objects/new").should route_to("test_objects#new")
    end

    it "routes to #show" do
      get("/test_objects/1").should route_to("test_objects#show", :id => "1")
    end

    it "routes to #edit" do
      get("/test_objects/1/edit").should route_to("test_objects#edit", :id => "1")
    end

    it "routes to #create" do
      post("/test_objects").should route_to("test_objects#create")
    end

    it "routes to #update" do
      put("/test_objects/1").should route_to("test_objects#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/test_objects/1").should route_to("test_objects#destroy", :id => "1")
    end

  end
end
