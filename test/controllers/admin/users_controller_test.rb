# frozen_string_literal: true

require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      sign_in :admin

      get admin_users_url
      assert_response :success
    end
  end
end
