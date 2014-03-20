require "spec_helper"

feature "Use full post-redirect-get displaying original params and errors on redirect" do
  let(:existing_example) { ExamplePrg.create(subject: 'existing test input', body: 'test body', published: true) }

  scenario "ensure secure environment for accurate test" do
    # Check that environment tested is actually secure (without selenium)
    visit new_error_duplicator_path
    expect(page.response_headers["Cache-Control"]).to include("no-cache, no-store")
  end

  scenario "within a secure environment with browser history disallowed", js: true do
    ExamplePrg.count.should eq(0)

    # Create error
    visit new_example_prg_path
    fill_in "Subject", :with => existing_example.subject
    click_button "Create Example prg"
    expect(page).to have_text("Subject has already been taken")

    # Should have set the error on the object
    expect(page).to have_field('Subject', with: existing_example.subject)

    # Should have redirected back
    expect(page.current_path).to eq(new_example_prg_path)

    # Should create successfully following error
    fill_in "Subject", :with => "testing NEW input"
    click_button "Create Example prg"
    expect(page).to have_text("Example prg was successfully created.")

    ExamplePrg.count.should eq(2)

    # On click of back button
    page.execute_script("window.history.back();")
    page.find('body') #wait till body element present

    # Should go back to a blank 'new' page
    expect(page).to have_text("New example_prg")
    expect(page.current_path).to eq(new_example_prg_path)
    expect(page).not_to have_text("Subject has already been taken") #no errors

    # Browser specific redirection
    case $selenium_display.browser.to_sym
    when :firefox, :"Internet Explorer"
      # Backs to the new page being completely empty
      expect(page).to have_field('Subject', with: "")
    when :chrome, :safari
      # Backs to the new page with original entries already loaded
      expect(page).to have_field('Subject', with: "testing NEW input")
    else
      raise "Error - Unhandled browser: #{$selenium_display.browser.to_sym}"
    end
  end

  scenario "ensure normal browser history environment for accurate test" do
    # Check that environment tested is not secure
    #  -> Selenium driver cannot check response headers
    visit edit_example_prg_path(existing_example)
    expect(page.response_headers["Cache-Control"]).not_to include("no-cache, no-store")
  end

  scenario "within a normal browser history environment", js: true do
    # Edit page has no secure headers set
    visit edit_example_prg_path(existing_example)

    # Create error
    fill_in "Subject", :with => ""
    click_button "Update Example prg"

    # Should redirect back to edit page with errors
    expect(page.current_path).to eq(edit_example_prg_path(existing_example))
    expect(page).to have_text("Subject can't be blank")
    expect(page).to have_field('Subject', with: "")

    # Edit successfully
    fill_in "Subject", :with => "updated test input"
    click_button "Update Example prg"
    expect(page).to have_text("Example prg was successfully updated.")

    # Should have redirected back
    expect(page.current_path).to eq(example_prg_path(existing_example))

    # On click of back button
    page.execute_script("window.history.back();")

    # Browser specific redirection
    case $selenium_display.browser.to_sym
    when :"Internet Explorer"
      # IE8 is unstable, sometimes skips back to 'show' or to 'edit' or sometimes nothing at all
      # expect(page.current_path).to eq(example_prg_path(existing_example))
      # expect(page).not_to have_text("Subject can't be blank")
    else
      # Should have redirected back to edit page with errors
      expect(page.current_path).to eq(edit_example_prg_path(existing_example))
      expect(page).to have_text("Subject can't be blank")
      expect(page).to have_field('Subject', with: "updated test input")
      expect(page).to have_field('Published', with: 1)
    end
  end
end
