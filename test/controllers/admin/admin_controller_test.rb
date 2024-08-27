# frozen_string_literal: true

require "test_helper"

module Admin
  class AdminControllerTest < ActionDispatch::IntegrationTest
    test "admin user can get index" do
      sign_in :admin

      get admin_root_url
      assert_response :success
    end

    test "logged in user can't get index" do
      sign_in :bugs

      get admin_root_url
      assert_response :not_found
    end

    test "anonymous user can't get index" do
      get admin_root_url
      assert_response :not_found
    end
  end
end
