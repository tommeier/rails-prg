require "spec_helper"

feature "Standard Rails", js: true do
  scenario "render on errors triggering browser cache error in secure environment", js: true do
    ErrorDuplicator.count.should eq(0)

    # Create initial object
    visit new_error_duplicator_path

    fill_in "Subject", :with => "testing input"
    click_button "Create Error duplicator"
    expect(page).to have_text("Error duplicator was successfully created.")
    expect(page.current_path).to eq(error_duplicator_path(ErrorDuplicator.first))

    # Create new with an error
    visit new_error_duplicator_path
    fill_in "Subject", :with => "testing input"
    click_button "Create Error duplicator"
    expect(page).to have_text("Subject has already been taken")

    # Should have set the error on the object
    expect(page).to have_field('Subject', with: "testing input")

    # Should *not* have redirected back
    expect(page.current_path).to eq(error_duplicators_path)

    # Should create successfully following an error
    fill_in "Subject", :with => "testing NEW input"
    click_button "Create Error duplicator"
    expect(page).to have_text("Error duplicator was successfully created.")

    ErrorDuplicator.count.should eq(2)

    # On click of back button
    page.execute_script("window.history.back();")

    # Cache miss error displayed for specific browser
    case $selenium_display.browser.to_sym
    when :firefox
      expect(page.find("h1#errorTitleText")).to have_text("Document Expired")
      expect(page.find("p#errorShortDescText")).to have_text("This document is no longer available.")
      expect(page.find("div#errorLongDesc")).to have_text("The requested document is not available in Firefox's cache")
      expect(page.current_path).to eq(error_duplicators_path)
    when :chrome
      within "div#main-frame-error" do
        expect(page.find("h1")).to have_text("Confirm Form Resubmission")
        click_button "More" #triggers chrome to load error code
        expect(page.find("div.error-code")).to have_text("Error code: ERR_CACHE_MISS")
      end
    else
      raise "Error - Unhandled browser"
    end
  end

  scenario "render on errors working normally in non-secure environment with browser history", js: true do
    original = ErrorDuplicator.create(subject: 'existing test input', body: 'test body', published: true)

    # Edit page has no secure headers set
    visit edit_error_duplicator_path(original)

    fill_in "Subject", :with => ""
    click_button "Update Error duplicator"
    expect(page).to have_text("Subject can't be blank")
    expect(page).to have_field('Subject', with: "")
    expect(page.current_path).to eq(error_duplicator_path(original))

    # Edit successfully
    fill_in "Subject", :with => "updated test input"
    click_button "Update Error duplicator"
    expect(page).to have_text("Error duplicator was successfully updated.")

    # Should *not* have redirected back
    expect(page.current_path).to eq(error_duplicator_path(original))

    # On click of back button
    page.execute_script("window.history.back();")

    # Browser specific way of handling 'back' with errors in non-secure environment
    case $selenium_display.browser.to_sym
    when :firefox
      # Backs all the way back to edit page without errors (pre-post)
      expect(page.current_path).to eq(edit_error_duplicator_path(original))
      page.should have_content("Editing error_duplicator")
      expect(page).to_not have_text("Subject can't be blank")
      expect(page).to have_field('Subject', with: "") #Posted value
    when :chrome
      # Backs all the way back to show page with errors (post -> rendered error)
      expect(page.current_path).to eq(error_duplicator_path(original))
      page.should have_content("Editing error_duplicator")
      expect(page).to have_text("Subject can't be blank")
      expect(page).to have_field('Subject', with: "updated test input") #updated value
    else
      raise "Error - Unhandled browser"
    end
  end
end
