# frozen_string_literal: true

require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in :admin

    get admin_users_url
    assert_response :success
  end
end
