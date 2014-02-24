require 'spec_helper'

describe "test_objects/index" do
  before(:each) do
    assign(:test_objects, [
      stub_model(TestObject,
        :subject => "MyText",
        :body => "MyText",
        :published => false
      ),
      stub_model(TestObject,
        :subject => "MyText",
        :body => "MyText",
        :published => false
      )
    ])
  end

  it "renders a list of test_objects" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
