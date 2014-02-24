require 'spec_helper'

describe "TestObjects" do
  describe "GET /test_objects" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get test_objects_path
      response.status.should be(200)
    end
  end
end
