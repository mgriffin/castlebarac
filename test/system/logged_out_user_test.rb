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
    within("#login") do
      click_link_or_button "Log in"
    end

    assert_selector "a", text: "Log out"
  end

  test "Can register" do
    visit login_url
    fill_in "Email", with: "coyote@acme.fake"
    fill_in "Password", with: "carrots"
    fill_in "Password confirmation", with: "carrots"
    within("#register") do
      click_link_or_button "Register"
    end

    assert_selector "div", text: "Signed up successfully"
  end
end
