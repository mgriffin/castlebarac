# frozen_string_literal: true

require "application_system_test_case"

class LoggedOutUserTest < ApplicationSystemTestCase
  test "Visiting the root page" do
    visit root_url

    assert_selector "a", text: "Log in"
  end

  test "Logging in" do
    visit root_url
    click_on "Log in"
    fill_in "Email Address:", with: "bugs@acme.fake"
    fill_in "Password:", with: "carrots"
    within("#new_user") do
      click_link_or_button "Log in"
    end

    assert_selector "a", text: "Log out"
  end

  test "Can register" do
    Capybara.current_session.driver.with_playwright_page do |page|
      visit root_url
      page.get_by_text("Login").click
      page.get_by_text("Register").click
      fill_in "user_email", with: "coyote@acme.fake"
      fill_in "Password", with: "carrots"
      fill_in "Password confirmation", with: "carrots"
      within("#new_user") do
        click_link_or_button "Register"
      end

      assert_selector "div", text: "Signed up successfully"
    end
  end
end
