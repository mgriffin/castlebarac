# frozen_string_literal: true

require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "logged in user can get index" do
    sign_in :bugs

    get admin_index_url
    assert_response :success
  end

  test "anonymous user can't get index" do
    get admin_index_url
    assert_response :forbidden
  end
end
