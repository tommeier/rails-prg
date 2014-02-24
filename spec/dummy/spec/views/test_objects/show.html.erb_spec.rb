require 'spec_helper'

describe "test_objects/show" do
  before(:each) do
    @test_object = assign(:test_object, stub_model(TestObject,
      :subject => "MyText",
      :body => "MyText",
      :published => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/false/)
  end
end
