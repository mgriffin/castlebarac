# frozen_string_literal: true

require "test_helper"

# Parents asking to be linked to their child, for an admin to approve
class ProfileChildClaimsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:bugs) }

  test "the profile page links to it" do
    get profile_url

    assert_select "a[href=?]", new_profile_child_claim_path
  end

  test "asks which person with the name is their child" do
    post profile_child_claims_url, params: { name: "Snörí Snöríssøň" }

    assert_response :unprocessable_content
    assert_select "input[type=radio][name=child_id][value=?]", people(:snori).id.to_s
  end

  test "says when there's no one with the name" do
    post profile_child_claims_url, params: { name: "Nobody Here" }

    assert_response :unprocessable_content
    assert_select ".alert", /couldn't find anyone called Nobody Here/
  end

  test "picking someone makes a claim for an admin to approve" do
    post profile_child_claims_url, params: { name: "Snörí Snöríssøň", child_id: people(:snori).id }

    assert_redirected_to profile_url
    assert_equal people(:snori), users(:bugs).child_claims.sole.child
    assert_empty people(:bugsbunny).children

    follow_redirect!
    assert_select "##{dom_id(users(:bugs).child_claims.sole)}", /Snörí/
  end

  test "can't claim someone who doesn't have the name they typed" do
    post profile_child_claims_url, params: { name: "Snörí Snöríssøň", child_id: people(:gabby).id }

    assert_response :unprocessable_content
    assert_empty users(:bugs).child_claims
  end

  test "doesn't offer someone they've already asked for" do
    users(:bugs).child_claims.create!(child: people(:snori))

    post profile_child_claims_url, params: { name: "Snörí Snöríssøň", child_id: people(:snori).id }

    assert_response :unprocessable_content
    assert_equal 1, users(:bugs).child_claims.count
  end

  test "can cancel a claim" do
    claim = users(:bugs).child_claims.create!(child: people(:snori))

    delete profile_child_claim_url(claim)

    assert_redirected_to profile_url
    assert_not ChildClaim.exists?(claim.id)
  end

  test "can't cancel someone else's claim" do
    claim = users(:coach).child_claims.create!(child: people(:snori))

    delete profile_child_claim_url(claim)

    assert_response :not_found
    assert ChildClaim.exists?(claim.id)
  end

  test "has to fill out their own details first" do
    sign_in users(:gabby)

    get new_profile_child_claim_url

    assert_redirected_to new_profile_url
  end
end
