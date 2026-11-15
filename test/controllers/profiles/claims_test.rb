# frozen_string_literal: true

require "test_helper"

# Claiming an existing person from the profile form, for an admin to approve
class ProfileClaimsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:gabby) }

  def create_profile(firstname, surname, claim: nil)
    post profile_url, params: { profile: { firstname:, surname:, claim: }.compact }
  end

  test "asks if they're someone already on the site with that name" do
    assert_no_difference -> { Person.count } do
      create_profile("Gabby", "GABBY")
    end

    assert_response :unprocessable_content
    assert_select "input[type=radio][name='profile[claim]'][value=?]", people(:gabby).id.to_s
    assert_select "input[type=radio][name='profile[claim]'][value=new]"
  end

  test "never offers someone who already has an account" do
    create_profile("Ad", "Min")

    assert_redirected_to profile_url
    assert_not_equal people(:admin), users(:gabby).reload.person
  end

  test "picking someone makes a claim for an admin to approve" do
    assert_no_difference -> { Person.count } do
      create_profile("Gabby", "Gabby", claim: people(:gabby).id)
    end

    assert_redirected_to new_profile_url
    assert_nil users(:gabby).reload.person
    assert_equal people(:gabby), users(:gabby).person_claims.sole.person

    follow_redirect!
    assert_select "h1", "Waiting for an admin"
    assert_select ".banner", count: 0
  end

  test "can't claim someone who wasn't offered" do
    create_profile("Gabby", "Gabby", claim: people(:bugsbunny).id)

    assert_response :unprocessable_content
    assert_not PersonClaim.exists?(user: users(:gabby))
  end

  test "picking none of them makes a new person" do
    assert_difference -> { Person.count } => 1 do
      create_profile("Gabby", "Gabby", claim: "new")
    end

    assert_redirected_to profile_url
    assert_equal "gabby-gabby-2", users(:gabby).reload.person.slug
    assert_nil people(:gabby).reload.user
    assert_not PersonClaim.exists?(user: users(:gabby))
  end

  test "a claim waiting for approval can be cancelled" do
    create_profile("Gabby", "Gabby", claim: people(:gabby).id)

    assert_no_difference -> { Person.count } do
      create_profile("Gabby", "Gabby", claim: "new")
    end
    assert_redirected_to new_profile_url

    delete profile_claim_url
    assert_redirected_to new_profile_url
    assert_not PersonClaim.exists?(user: users(:gabby))
  end

  test "after a rejection they're told, and that person isn't offered again" do
    PersonClaim.create!(user: users(:gabby), person: people(:gabby)).reject!(users(:admin))

    get new_profile_url
    assert_select ".alert", /couldn't confirm that you're Gabby Gabby/

    create_profile("Gabby", "Gabby")
    assert_redirected_to profile_url
  end
end
