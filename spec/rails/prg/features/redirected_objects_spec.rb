require "spec_helper"

feature "Display redirection and display of form content and errors" do
  scenario "User redirects on error", js: true do
    visit "/test_objects/new"

    fill_in "Subject", :with => "testing input"
    click_button "Create Test Object"

    expect(page).to have_text("Test Object was successfully created.")
  end
end
