# frozen_string_literal: true

require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "should get index" do
      sign_in users(:admin)

      get admin_users_url
      assert_response :success
    end

    test "shows when users signed up and last logged in" do
      users(:bugs).update!(username: "bugs", created_at: 3.days.ago, current_sign_in_at: 2.hours.ago)
      users(:gabby).update!(username: "gabby", current_sign_in_at: nil)
      sign_in users(:admin)

      get admin_users_url

      assert_select "th", "Signed up"
      assert_select "th", "Last logged in"
      assert_select "td time", "3 days ago"
      assert_select "td time[title]", "about 2 hours ago"
      assert_select "td", "Not recorded"
    end
  end
end
