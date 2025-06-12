# frozen_string_literal: true

require "application_system_test_case"

class RegularUserTest < ApplicationSystemTestCase
  test "cannot create a post" do
    login_as(users(:bugs))

    refute_selector "a", text: "Admin"
  end

  test "can see comments on a story" do
    post = Post.first
    login_as(users(:bugs))

    visit post_url(post.url)

    assert_selector "h3", text: "Comments"
    assert_selector "input[type=submit][value=Post]"
  end

  test "can see events" do
    login_as(users(:bugs))

    visit events_url

    assert_selector "h2", text: "Upcoming Events"
    assert_selector "h2", text: "Past Events"
  end
end
