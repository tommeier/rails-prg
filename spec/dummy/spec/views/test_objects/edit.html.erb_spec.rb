require 'spec_helper'

describe "test_objects/edit" do
  before(:each) do
    @test_object = assign(:test_object, stub_model(TestObject,
      :subject => "MyText",
      :body => "MyText",
      :published => false
    ))
  end

  it "renders the edit test_object form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", test_object_path(@test_object), "post" do
      assert_select "textarea#test_object_subject[name=?]", "test_object[subject]"
      assert_select "textarea#test_object_body[name=?]", "test_object[body]"
      assert_select "input#test_object_published[name=?]", "test_object[published]"
    end
  end
end
