# frozen_string_literal: true

require "test_helper"

module Admin
  module Teams
    class MembershipsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      def membership(person, team)
        Membership.find_by(person: people(person), team: teams(team))
      end

      test "admins can add someone to a team" do
        sign_in users(:admin)

        assert_difference -> { Membership.count } => 1 do
          post admin_team_memberships_url(teams(:coaches)), params: { membership: { person_id: people(:bugsbunny).id } }
        end

        assert_redirected_to admin_team_url(teams(:coaches))
        assert_equal "Added Bugs Bunny to Coaches", flash[:notice]
        assert membership(:bugsbunny, :coaches)
      end

      test "adding someone who's already a member doesn't add them twice" do
        sign_in users(:admin)

        assert_no_difference -> { Membership.count } do
          post admin_team_memberships_url(teams(:coaches)), params: { membership: { person_id: people(:coach).id } }
        end

        assert_equal "Coach Watkins is already a member of Coaches", flash[:notice]
      end

      test "admins have to choose someone to add" do
        sign_in users(:admin)

        assert_no_difference -> { Membership.count } do
          post admin_team_memberships_url(teams(:coaches)), params: { membership: { person: "Nobody", person_id: "" } }
        end

        assert_redirected_to admin_team_url(teams(:coaches))
        assert_match "Choose someone", flash[:alert]
      end

      test "admins can remove someone from a team" do
        sign_in users(:admin)

        delete admin_team_membership_url(teams(:coaches), membership(:coach, :coaches))

        assert_redirected_to admin_team_url(teams(:coaches))
        assert_equal "Removed Coach Watkins from Coaches", flash[:notice]
        assert_nil membership(:coach, :coaches)
      end

      test "admins can't remove themselves from the Admins team" do
        sign_in users(:admin)

        delete admin_team_membership_url(teams(:admins), membership(:admin, :admins))

        assert_equal "You can't remove yourself from the Admins team", flash[:alert]
        assert membership(:admin, :admins)
      end

      test "a membership can only be removed through its own team" do
        sign_in users(:admin)

        delete admin_team_membership_url(teams(:admins), membership(:coach, :coaches))

        assert_response :not_found
        assert membership(:coach, :coaches)
      end

      test "unknown teams are not found" do
        sign_in users(:admin)

        post admin_team_memberships_url("no-such-team"), params: { membership: { person_id: people(:bugsbunny).id } }

        assert_response :not_found
      end

      test "people who aren't admins can't change teams" do
        [users(:bugs), users(:coach)].each do |user|
          sign_in user

          assert_no_difference -> { Membership.count } do
            post admin_team_memberships_url(teams(:admins)), params: { membership: { person_id: user.person.id } }
          end
          assert_response :not_found

          delete admin_team_membership_url(teams(:admins), membership(:admin, :admins))
          assert_response :not_found
          assert membership(:admin, :admins)

          sign_out user
        end
      end

      test "anonymous visitors can't change teams" do
        assert_no_difference -> { Membership.count } do
          post admin_team_memberships_url(teams(:admins)), params: { membership: { person_id: people(:bugsbunny).id } }
        end
        assert_response :not_found

        delete admin_team_membership_url(teams(:admins), membership(:admin, :admins))
        assert_response :not_found
        assert membership(:admin, :admins)
      end
    end
  end
end
