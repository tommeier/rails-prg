require "spec_helper"

feature "Standard Rails render on errors" do
  let(:existing_example) { ErrorDuplicator.create(subject: 'anything', body: 'test body', published: true) }

  scenario "ensure secure environment for accurate test" do
    # Check that environment tested is actually secure (without selenium)
    visit new_error_duplicator_path
    expect(page.response_headers["Cache-Control"]).to include("no-cache, no-store")
  end

  scenario "triggering browser cache error in secure environment with browser history disabled", js: true do
    ErrorDuplicator.count.should eq(0)

    # Create new with an error
    visit new_error_duplicator_path
    fill_in "Subject", :with => existing_example.subject
    click_button "Create Error duplicator"
    expect(page).to have_text("Subject has already been taken")

    # Should have set the error on the object
    expect(page).to have_field('Subject', with: existing_example.subject)

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
        expect(page.find("div.error-code", visible: false)).to have_text("ERR_CACHE_MISS")
      end
    when :safari
      #Unable to duplicate except visually
      # safariDriver cannot handle alerts, or be aware of them
      # Behaviour: Safari shows 'confirm form resubmission' alert box
    when :"Internet Explorer"
      # IE 8
      expect(page.body).to have_text("The local copy of this webpage is out of date, and the website requires that you download it again.")
    else
      raise "Error - Unhandled browser: #{$selenium_display.browser.to_sym}"
    end
  end

  scenario "ensure non-secure environment for accurate test" do
    # Check that environment tested is not secure (without selenium)
    visit edit_error_duplicator_path(existing_example)
    expect(page.response_headers["Cache-Control"]).not_to include("no-cache, no-store")
  end

  scenario "working normally in non-secure environment with browser history", js: true do
    # Edit page has no secure headers set
    visit edit_error_duplicator_path(existing_example)

    fill_in "Subject", :with => ""
    click_button "Update Error duplicator"
    expect(page).to have_text("Subject can't be blank")
    expect(page).to have_field('Subject', with: "")
    expect(page.current_path).to eq(error_duplicator_path(existing_example))

    # Edit successfully
    fill_in "Subject", :with => "updated test input"
    click_button "Update Error duplicator"
    expect(page).to have_text("Error duplicator was successfully updated.")

    # Should *not* have redirected back
    expect(page.current_path).to eq(error_duplicator_path(existing_example))

    # On click of back button
    page.execute_script("window.history.back();")

    # Browser specific way of handling 'back' with errors in non-secure environment
    case $selenium_display.browser.to_sym
    when :firefox
      # Backs all the way back to edit page without errors (pre-post)
      expect(page.current_path).to eq(edit_error_duplicator_path(existing_example))
      page.should have_content("Editing error_duplicator")
      expect(page).to_not have_text("Subject can't be blank")
      expect(page).to have_field('Subject', with: "") #Posted value
    when :chrome, :safari
      # Backs all the way back to show page with errors (post -> rendered error)
      expect(page.current_path).to eq(error_duplicator_path(existing_example))
      page.should have_content("Editing error_duplicator")
      expect(page).to have_text("Subject can't be blank")
      expect(page).to have_field('Subject', with: "updated test input") #updated value
    when :"Internet Explorer"
      # Occasionally IE8 barfs with this error page in Sauce. Ignore.
      unless page.current_path == "/repost.htm"
        # Backs all the way back to edit page without errors but content filled
        expect(page.current_path).to eq(edit_error_duplicator_path(existing_example))
        page.should have_content("Editing error_duplicator")
        expect(page).to_not have_text("Subject can't be blank")
        expect(page).to have_field('Subject', with: "updated test input") #Posted value
      end
    else
      raise "Error - Unhandled browser: #{$selenium_display.browser.to_sym}"
    end
  end
end
