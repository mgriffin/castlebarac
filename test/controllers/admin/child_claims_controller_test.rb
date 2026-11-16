# frozen_string_literal: true

require "test_helper"

module Admin
  class ChildClaimsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @claim = ChildClaim.create!(user: users(:bugs), child: people(:snori))
    end

    test "only admins can see and review requests" do
      get admin_child_claims_url
      assert_response :not_found

      sign_in users(:coach)
      get admin_child_claims_url
      assert_response :not_found
      patch approve_admin_child_claim_url(@claim)
      assert_response :not_found

      assert @claim.reload.pending?
    end

    test "lists requests waiting for approval" do
      sign_in users(:admin)

      get admin_child_claims_url

      assert_response :success
      assert_select "##{dom_id(@claim)}", /Bugs Bunny.*Snörí/m
    end

    test "admins can approve a request" do
      sign_in users(:admin)

      patch approve_admin_child_claim_url(@claim)

      assert_redirected_to admin_child_claims_url
      assert_equal "Linked Bugs Bunny as the parent of Snörí Snöríssøň", flash[:notice]
      assert @claim.reload.approved?
      assert_includes people(:bugsbunny).children, people(:snori)
    end

    test "admins can reject a request" do
      sign_in users(:admin)

      patch reject_admin_child_claim_url(@claim)

      assert_redirected_to admin_child_claims_url
      assert @claim.reload.rejected?
      assert_not_includes people(:bugsbunny).children, people(:snori)
    end
  end
end
