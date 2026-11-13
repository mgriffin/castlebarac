# frozen_string_literal: true

require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def create_profile(firstname, surname)
    post profile_url, params: { profile: { firstname:, surname: } }
  end

  test "people who aren't signed in are asked to sign in" do
    get profile_url
    assert_redirected_to new_user_session_url

    create_profile("Gabby", "Gabby")
    assert_redirected_to new_user_session_url
  end

  test "users without a person are asked to fill out their details" do
    sign_in users(:gabby)

    get profile_url
    assert_redirected_to new_profile_url

    get edit_profile_url
    assert_redirected_to new_profile_url
  end

  test "the new profile form starts with the name they signed up with" do
    users(:gabby).update!(username: "Juliette NIC SUIBHNE")
    sign_in users(:gabby)

    get new_profile_url

    assert_response :success
    assert_select "input[name='profile[firstname]'][value='Juliette']"
    assert_select "input[name='profile[surname]'][value='Nic Suibhne']"
  end

  test "creating a profile makes a new person even if someone has that name" do
    sign_in users(:gabby)

    assert_difference -> { Person.count } => 1 do
      create_profile("Gabby", "Gabby")
    end

    assert_redirected_to profile_url
    person = users(:gabby).reload.person
    assert_not_equal people(:gabby), person
    assert_equal "gabby-gabby", person.slug
    assert_nil people(:gabby).reload.user
  end

  test "using an admin's name doesn't take over their person or make you an admin" do
    sign_in users(:gabby)

    create_profile("Ad", "Min")

    assert_not users(:gabby).reload.admin?
    assert_equal users(:admin), people(:admin).reload.user
  end

  test "users who already have a person can't make another" do
    sign_in users(:bugs)

    get new_profile_url
    assert_redirected_to edit_profile_url

    assert_no_difference -> { Person.count } do
      create_profile("Ad", "Min")
    end
    assert_redirected_to edit_profile_url
    assert_equal people(:bugsbunny), users(:bugs).reload.person
  end

  test "users can change their name" do
    sign_in users(:bugs)

    get edit_profile_url
    assert_select "input[name='profile[firstname]'][value='Bugs']"

    patch profile_url, params: { profile: { firstname: "Bugsy", surname: "Bunny" } }

    assert_redirected_to profile_url
    assert_equal "Bugsy", people(:bugsbunny).reload.firstname
  end
end
