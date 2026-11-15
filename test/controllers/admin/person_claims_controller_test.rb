# frozen_string_literal: true

require "test_helper"

module Admin
  class PersonClaimsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @claim = PersonClaim.create!(user: users(:gabby), person: people(:gabby))
    end

    test "only admins can see and review claims" do
      get admin_person_claims_url
      assert_response :not_found

      sign_in users(:coach)
      get admin_person_claims_url
      assert_response :not_found
      patch approve_admin_person_claim_url(@claim)
      assert_response :not_found

      assert @claim.reload.pending?
    end

    test "lists claims waiting for approval, with the person's teams" do
      people(:gabby).teams << teams(:coaches)
      sign_in users(:admin)

      get admin_person_claims_url

      assert_response :success
      assert_select "##{dom_id(@claim)}", /gabbygabby@acme\.fake.*Gabby Gabby.*Coaches/m
    end

    test "admins can approve a claim" do
      sign_in users(:admin)

      patch approve_admin_person_claim_url(@claim)

      assert_redirected_to admin_person_claims_url
      assert_equal "Linked gabbygabby@acme.fake to Gabby Gabby", flash[:notice]
      assert @claim.reload.approved?
      assert_equal people(:gabby), users(:gabby).reload.person
    end

    test "says why a claim can't be approved" do
      people(:gabby).update!(user: users(:bugs).tap { people(:bugsbunny).update!(user: nil) })
      sign_in users(:admin)

      patch approve_admin_person_claim_url(@claim)

      assert_equal "Gabby Gabby is already linked to another account", flash[:alert]
      assert @claim.reload.pending?
    end

    test "admins can reject a claim" do
      sign_in users(:admin)

      patch reject_admin_person_claim_url(@claim)

      assert_equal "Rejected gabbygabby@acme.fake's claim to be Gabby Gabby", flash[:notice]
      assert @claim.reload.rejected?
      assert_nil users(:gabby).reload.person
    end

    test "a claim that's been reviewed can't be reviewed again" do
      @claim.reject!(users(:admin))
      sign_in users(:admin)

      patch approve_admin_person_claim_url(@claim)

      assert_response :not_found
      assert @claim.reload.rejected?
    end
  end
end
