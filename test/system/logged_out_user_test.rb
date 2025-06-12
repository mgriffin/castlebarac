# frozen_string_literal: true

require "application_system_test_case"

class LoggedOutUserTest < ApplicationSystemTestCase
  test "can see the root page" do
    visit root_url

    assert_title "Castlebar A.C. - Home"
    assert_selector "a", text: "Log in"
  end

  test "can see the news archive page" do
    visit posts_url

    assert_title "Castlebar A.C. - News"
    assert_selector "a", text: "Log in"
  end

  test "does not see comments on a story" do
    post = Post.first

    visit post_url(post.url)

    refute_selector "h3", text: "Comments"
    refute_selector "button", text: "Post"
  end

  test "can register" do
    visit root_url
    click_on "Log in"
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
