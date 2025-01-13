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
  end
end
