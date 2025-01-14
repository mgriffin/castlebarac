# frozen_string_literal: true

require "application_system_test_case"

class RegularUserTest < ApplicationSystemTestCase
  test "Regular user cannot create a post" do
    visit root_url
    click_on "Log in"
    fill_in "Email Address:", with: "bugs@acme.fake"
    fill_in "Password:", with: "carrots"
    within("#new_user") do
      click_link_or_button "Log in"
    end

    refute_selector "a", text: "Admin"
  end
end
