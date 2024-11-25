require "application_system_test_case"

class RegularUserTest < ApplicationSystemTestCase
  test "Regular user cannot create a post" do
    visit root_url
    click_on "Log in"
    fill_in "Email Address:", with: "bugs@acme.fake"
    fill_in "Password:", with: "carrots"
    click_button "Log in"

    refute_selector "a", text: "Admin"
  end
end
