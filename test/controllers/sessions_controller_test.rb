# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "get login page" do
    get login_url

    assert_response :success
  end

  test "can't log in" do
    post login_url, params: { user: { email: "not-a-user@acme.fake", password: "carrots" } }

    assert_redirected_to login_url
    assert_not cookies[:session_token].present?
  end

  test "can log in" do
    post login_url, params: { user: { email: "bugs@acme.fake", password: "carrots" } }

    assert_redirected_to root_url
    assert cookies[:session_token].present?
  end

  test "can log out" do
    sign_in :bugs

    get logout_url

    assert_redirected_to root_url
    assert_not cookies[:session_token].present?
  end
end
