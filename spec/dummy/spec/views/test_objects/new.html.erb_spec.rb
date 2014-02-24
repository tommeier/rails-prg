require 'spec_helper'

describe "test_objects/new" do
  before(:each) do
    assign(:test_object, stub_model(TestObject,
      :subject => "MyText",
      :body => "MyText",
      :published => false
    ).as_new_record)
  end

  it "renders new test_object form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", test_objects_path, "post" do
      assert_select "textarea#test_object_subject[name=?]", "test_object[subject]"
      assert_select "textarea#test_object_body[name=?]", "test_object[body]"
      assert_select "input#test_object_published[name=?]", "test_object[published]"
    end
  end
end
