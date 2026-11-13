# frozen_string_literal: true

require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def sign_up(username)
    post user_registration_url, params: { user: {
      email: "newcomer@acme.fake", username:, password: "carrots123", password_confirmation: "carrots123"
    } }
    User.find_by!(email: "newcomer@acme.fake")
  end

  test "signing up with an admin's name doesn't take over their person" do
    user = assert_no_difference -> { Person.count } do
      sign_up("Ad Min")
    end

    assert_nil user.person
    assert_not user.admin?
    assert_equal users(:admin), people(:admin).reload.user
    assert users(:admin).reload.admin?
  end

  test "new users without a person can use the site and are asked for their details" do
    sign_up("Someone New")
    follow_redirect!

    assert_response :success
    assert_select "a[href='#{new_profile_path}']", "fill out your details"
  end
end
