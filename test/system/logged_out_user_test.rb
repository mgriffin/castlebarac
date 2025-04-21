# frozen_string_literal: true

require "application_system_test_case"

class LoggedOutUserTest < ApplicationSystemTestCase
  test "Visiting the root page" do
    visit root_url

    assert_selector "a", text: "Members"
  end

  test "Logging in" do
    visit root_url
    click_on "Members"
    fill_in "Email Address:", with: "bugs@acme.fake"
    fill_in "Password:", with: "carrots"
    within("#new_user") do
      click_link_or_button "Log in"
    end

    assert_selector "a", text: "Log out"
  end

  test "Can register" do
    visit root_url
    click_on "Members"
    click_link_or_button "Register"
    ensure_turbo_frames_are_complete
    within("#new_user") do
      fill_in "Email", with: "coyote@acme.fake"
      fill_in "Password", with: "carrots"
      fill_in "Password confirmation", with: "carrots"
      click_link_or_button "Sign up"
    end

    assert_selector "div", text: "You have signed up successfully"
  end
end
