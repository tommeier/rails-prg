require "spec_helper"

feature "Display redirection and display of form content and errors" do
  scenario "User redirects on error", js: true do
    puts TestObject.inspect
    puts TestObject.class.inspect
    TestObject.count.should eq(0)

    # Create initial object
    visit "/test_objects/new"
    fill_in "Subject", :with => "testing input"
    click_button "Create Test object"
    expect(page).to have_text("Test object was successfully created.")
    expect(page.current_path).to eq(test_object_path(TestObject.first))

    # Create error
    visit "/test_objects/new"
    fill_in "Subject", :with => "testing input"
    click_button "Create Test object"
    expect(page).to have_text("Subject has already been taken")

    # Should have set the error on the object
    expect(page).to have_field('Subject', with: "testing input")

    # Should have redirected back
    expect(page.current_path).to eq(new_test_object_path)

    # Should create successfully following error
    fill_in "Subject", :with => "testing NEW input"
    click_button "Create Test object"
    expect(page).to have_text("Test object was successfully created.")

    TestObject.count.should eq(2)

    # On click of back button
    page.execute_script("window.history.back();")

    expect(page).to have_text("Editing test_object")
    expect(page.current_path).to eq(edit_test_object_path(TestObject.first))
  end
end
