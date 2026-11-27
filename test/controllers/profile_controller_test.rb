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

  test "shows your details, membership and children" do
    sign_in users(:bugs)
    people(:bugsbunny).club_memberships.create!(year: 2025)
    event = Event.create!(title: "Mayo XC", start_time: Time.zone.local(2026, 10, 11, 11))
    people(:ciara).results.create!(race: event.races.create!(name: "U12 Girls"), position: 4)
    users(:bugs).child_claims.create!(child: people(:snori))

    get profile_url

    assert_select ".person-header h2", "Bugs Bunny"
    assert_select ".person-header", /bugs@acme.fake/
    assert_select ".person-chip", "Member 2025"
    assert_select ".person-header a[href=?]", edit_profile_path
    assert_select ".person-header a[href=?]", person_path(people(:bugsbunny))
    assert_select ".person-child", /Ciara Walsh\s+#{people(:ciara).age_group}\s+1 result, most recently\s+Mayo XC/
    assert_select ".person-child", /Aoife Moran\s+No results yet/
    assert_select ".person-child--pending", /Snörí Snöríssøň\s+Waiting for an admin/
    assert_select ".person-child--add[href=?]", new_profile_child_claim_path
  end

  test "loads all the children's parents at once" do
    sign_in users(:bugs)

    # One query for the children and one for all their parents, however many there are
    assert_queries_match(/person_relationships/, count: 2) { get profile_url }
  end
end
