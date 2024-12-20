# frozen_string_literal: true

require "application_system_test_case"

class AdminUserTest < ApplicationSystemTestCase
  test "Admin user can create a post" do
    visit root_url
    click_on "Log in"
    fill_in "Email Address:", with: "admin@acme.fake"
    fill_in "Password:", with: "carrots"
    within("#login") do
      click_link_or_button "Log in"
    end

    click_on "Admin"
    click_on "Add a new post"

    title = Faker::Lorem.sentence
    fill_in "Title:", with: title
    fill_in_rich_text_area "Body:", with: Faker::Lorem.paragraph
    click_link_or_button "Post it"

    assert_selector "div", text: "Added #{title}"
  end
end
