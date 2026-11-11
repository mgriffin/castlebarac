# frozen_string_literal: true

require "test_helper"

module Admin
  module Users
    class AdminMembershipsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      def admin?(user)
        teams(:admins).people.include?(user.reload.person)
      end

      test "admins can add someone to the Admins team" do
        sign_in users(:admin)

        post admin_user_admin_membership_url(users(:bugs))

        assert_redirected_to admin_users_url
        assert_equal "Bugs Bunny is now an admin", flash[:notice]
        assert admin?(users(:bugs))
      end

      test "adding someone twice doesn't add them twice" do
        sign_in users(:admin)

        assert_difference -> { Membership.count } => 1 do
          2.times { post admin_user_admin_membership_url(users(:bugs)) }
        end
      end

      test "can't add someone who isn't linked to a person" do
        sign_in users(:admin)

        assert_no_difference -> { Membership.count } do
          post admin_user_admin_membership_url(users(:gabby))
        end
        assert_redirected_to admin_users_url
        assert_match "isn't linked to a person", flash[:alert]
      end

      test "admins can remove someone from the Admins team" do
        teams(:admins).people << people(:bugsbunny)
        sign_in users(:admin)

        delete admin_user_admin_membership_url(users(:bugs))

        assert_redirected_to admin_users_url
        assert_equal "Bugs Bunny is no longer an admin", flash[:notice]
        assert_not admin?(users(:bugs))
      end

      test "admins can't remove themselves" do
        sign_in users(:admin)

        delete admin_user_admin_membership_url(users(:admin))

        assert_equal "You can't remove yourself from the Admins team", flash[:alert]
        assert admin?(users(:admin))
      end

      test "other users can't change the Admins team" do
        sign_in users(:bugs)

        post admin_user_admin_membership_url(users(:bugs))

        assert_response :not_found
        assert_not admin?(users(:bugs))

        delete admin_user_admin_membership_url(users(:admin))

        assert_response :not_found
        assert admin?(users(:admin))
      end
    end
  end
end
