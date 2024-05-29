require "application_system_test_case"

class HierarchiesTest < ApplicationSystemTestCase
  test "logging in changes the login link to log out" do
    Flipper.enable :banner
    Flipper.enable :login

    visit root_path

    refute_selector "a", text: "Log out"
    click_on "Log in"

    fill_in "Email", with: "bugs@acme.fake"
    fill_in "Password", with: "fake_password"

    click_button "Log in"

    assert_selector "a", text: "Log out"
    refute_selector "a", text: "Log in"
  end

  test "can approve a user" do
    Flipper.enable :banner
    Flipper.enable :login

    visit new_user_session_path
    fill_in "Email", with: "bugs@acme.fake"
    fill_in "Password", with: "fake_password"
    click_button "Log in"
    assert_selector "a", text: "Log out"

    visit users_path

    assert_text "There are no approved users"
    refute_text "There are no unapproved users"

    click_on "Approve bugs@acme.fake"

    refute_text "There are no approved users"
    assert_text "There are no unapproved users"
  end
end
